# frozen_string_literal: true

module DiscourseSubscriptions
  class SubscribeController < ::ApplicationController
    include DiscourseSubscriptions::Stripe
    include DiscourseSubscriptions::Group

    requires_plugin DiscourseSubscriptions::PLUGIN_NAME

    before_action :set_api_key
    requires_login except: %i[index contributors show]

    # In app/controllers/discourse_subscriptions/subscribe_controller.rb

    def index
      begin
        products = []
        if is_stripe_configured?
          # Fetch all products from our local database
          local_products = ::DiscourseSubscriptions::Product.all

          local_products.each do |p|
            begin
              product_data = ::Stripe::Product.retrieve(p.external_id)
              next unless product_data.active

              # FIX: Fetch plans specifically for this product_data.id
              # This is more reliable than fetching all plans at once.
              product_plans_data = ::Stripe::Price.list(
                product: product_data.id,
                active: true,
                limit: 100 # It's rare for a single product to have > 100 prices
              )

              products << {
                id: product_data.id,
                name: product_data.name,
                description: PrettyText.cook(product_data.description || product_data.metadata[:description]),
                subscribed: current_user_products.include?(product_data.id),
                repurchaseable: product_data.metadata[:repurchaseable],
                metadata: product_data.metadata.to_h, # Pass all metadata
                plans: serialize_plans(product_plans_data) # Use the fetched plans
              }
            rescue ::Stripe::InvalidRequestError => e
              Rails.logger.warn("[Subscriptions] Could not retrieve Stripe product with ID #{p.external_id}: #{e.message}")
              next
            end
          end
        end

        render_json_dump products.sort_by { |p| p[:name] }

      rescue ::Stripe::InvalidRequestError => e
        render_json_error e.message
      end
    end

    def contributors
      return unless SiteSetting.discourse_subscriptions_campaign_show_contributors
      contributor_ids = Set.new
      campaign_product = SiteSetting.discourse_subscriptions_campaign_product
      if campaign_product.present?
        contributor_ids.merge(Customer.where(product_id: campaign_product).last(5).pluck(:user_id))
      else
        contributor_ids.merge(Customer.last(5).pluck(:user_id))
      end
      contributors = ::User.where(id: contributor_ids)
      render_serialized(contributors, UserSerializer)
    end

    def show
      params.require(:id)
      begin
        product = ::Stripe::Product.retrieve(params[:id])
        plans = ::Stripe::Price.list(active: true, product: params[:id])
        response = { product: serialize_product(product), plans: serialize_plans(plans) }
        render_json_dump response
      rescue ::Stripe::InvalidRequestError => e
        render_json_error e.message
      end
    end

    def create
      params.require(:plan)
      begin
        plan = ::Stripe::Price.retrieve(params[:plan])
        if SiteSetting.discourse_subscriptions_payment_provider == "Razorpay"
          # Add this notes hash
          notes = {
            user_id: current_user.id,
            username: current_user.username,
            plan_id: plan.id
          }
          order =
            DiscourseSubscriptions::Providers::RazorpayProvider.create_order(
              plan[:unit_amount],
              plan[:currency].upcase,
              notes # Pass the notes here
            )
          render_json_dump order
        else
          params.require(:source)
          customer =
            find_or_create_customer(
              params[:source],
              params[:cardholder_name],
              params[:cardholder_address],
              )
          if params[:promo].present?
            promo_code = ::Stripe::PromotionCode.list({ code: params[:promo] })
            promo_code = promo_code[:data][0]
            if promo_code.blank?
              return render_json_error I18n.t("js.discourse_subscriptions.subscribe.invalid_coupon")
            end
          end
          recurring_plan = plan[:type] == "recurring"
          if recurring_plan
            trial_days = plan.dig(:metadata, :trial_period_days)
            promo_code_id = promo_code[:id] if promo_code
            subscription_params = {
              customer: customer[:id],
              items: [{ price: params[:plan] }],
              metadata: metadata_user,
              trial_period_days: trial_days,
              promotion_code: promo_code_id,
            }
            if SiteSetting.discourse_subscriptions_enable_automatic_tax
              subscription_params[:automatic_tax] = { enabled: true }
            end
            transaction = ::Stripe::Subscription.create(subscription_params)
            payment_intent = retrieve_payment_intent(transaction[:latest_invoice]) if transaction[:status] == "incomplete"
          else
            coupon_id = promo_code.dig(:coupon, :id) if promo_code
            invoice_params = { customer: customer[:id] }
            if SiteSetting.discourse_subscriptions_enable_automatic_tax
              invoice_params[:automatic_tax] = { enabled: true }
            end
            invoice = ::Stripe::Invoice.create(invoice_params)
            ::Stripe::InvoiceItem.create(
              customer: customer[:id],
              price: params[:plan],
              discounts: [{ coupon: coupon_id }],
              invoice: invoice[:id],
              )
            transaction = ::Stripe::Invoice.finalize_invoice(invoice[:id])
            payment_intent = retrieve_payment_intent(transaction[:id]) if transaction[:status] == "open"
            if payment_intent.nil?
              return(render_json_error I18n.t("js.discourse_subscriptions.subscribe.transaction_error"))
            end
            transaction = ::Stripe::Invoice.pay(invoice[:id]) if payment_intent[:status] == "successful"
          end
          finalize_transaction(transaction, plan) if transaction_ok(transaction)
          transaction = transaction.to_h.merge(transaction, payment_intent: payment_intent)
          render_json_dump transaction
        end
      rescue ::Stripe::InvalidRequestError => e
        render_json_error e.message
      rescue ::Razorpay::Error => e
        render_json_error e.message
      end
    end

    def finalize
      params.require(%i[plan transaction])
      begin
        price = ::Stripe::Price.retrieve(params[:plan])
        transaction = retrieve_transaction(params[:transaction])
        finalize_transaction(transaction, price) if transaction_ok(transaction)
        render_json_dump params[:transaction]
      rescue ::Stripe::InvalidRequestError => e
        render_json_error e.message
      end
    end

    def finalize_razorpay_payment
      params.require(%i[plan_id razorpay_payment_id razorpay_order_id razorpay_signature])
      begin
        is_valid = DiscourseSubscriptions::Providers::RazorpayProvider.verify_payment(
          params[:razorpay_payment_id],
          params[:razorpay_order_id],
          params[:razorpay_signature],
          )
        if is_valid
          plan = ::Stripe::Price.retrieve(params[:plan_id])
          transaction = {
            id: params[:razorpay_payment_id],
            customer: "cus_razorpay_#{current_user.id}"
          }
          finalize_discourse_subscription(transaction, plan)
          render json: success_json
        else
          render_json_error(I18n.t("discourse_subscriptions.card.declined"))
        end
      rescue ::Razorpay::Error => e
        render_json_error(e.message)
      rescue ::Stripe::InvalidRequestError => e
        render_json_error(e.message)
      end
    end

    def finalize_transaction(transaction, plan)
      finalize_discourse_subscription(transaction, plan)
    end


    private
    def finalize_discourse_subscription(transaction, plan)
      provider_name = SiteSetting.discourse_subscriptions_payment_provider

      group_name = plan.metadata.group_name if plan.metadata
      if group_name.present?
        group = ::Group.find_by(name: group_name)
        group&.add(current_user)
      end

      # --- START OF NEW LOGIC ---
      # Read the duration from the plan's metadata
      duration = plan.metadata.duration.to_i if plan.metadata&.duration

      # If a valid duration exists, calculate the expiry date
      expires_at = duration.present? && duration > 0 ? duration.days.from_now : nil
      # --- END OF NEW LOGIC ---

      customer = ::DiscourseSubscriptions::Customer.find_or_create_by!(user_id: current_user.id) do |c|
        c.customer_id = transaction[:customer]
      end

      customer.update!(
        customer_id: transaction[:customer],
        product_id: plan.product
      )

      ::DiscourseSubscriptions::Subscription.create!(
        customer_id: customer.id,
        external_id: transaction[:id],
        status: "active",
        provider: provider_name,
        plan_id: plan.id,
        duration: duration,     # Save the duration
        expires_at: expires_at  # Save the calculated expiry date
      )
    end

    def serialize_product(product)
      {
        id: product[:id],
        name: product[:name],
        description: PrettyText.cook(product[:metadata][:description]),
        subscribed: current_user_products.include?(product[:id]),
        repurchaseable: product[:metadata][:repurchaseable],
      }
    end

    def current_user_products
      return [] if current_user.nil?
      Customer
        .joins(:subscriptions)
        .where(user_id: current_user.id)
        .where(
          Subscription.arel_table[:status].eq(nil).or(
            Subscription.arel_table[:status].not_eq("canceled"),
            ),
          )
        .select(:product_id)
        .distinct
        .pluck(:product_id)
    end

    def serialize_plans(plans)
      plans[:data]
        .map do |plan|
        # Only include plans that have a price greater than 0
        next if plan.unit_amount.to_i == 0

        {
          id: plan.id,
          unit_amount: plan.unit_amount,
          currency: plan.currency,
          type: plan.type,
          recurring: plan.recurring,
          nickname: plan.nickname,
          metadata: plan.metadata.to_h
        }
      end
        .compact # Remove any nil values created by the 'next' keyword
        .sort_by { |plan| plan[:unit_amount] }
    end

    def find_or_create_customer(source, cardholder_name = nil, cardholder_address = nil)
      customer = Customer.find_by_user_id(current_user.id)
      cardholder_address =
        (
          if cardholder_address.present?
            {
              line1: cardholder_address[:line1],
              city: cardholder_address[:city],
              state: cardholder_address[:state],
              country: cardholder_address[:country],
              postal_code: cardholder_address[:postalCode],
            }
          else
            nil
          end
        )
      if customer.present?
        ::Stripe::Customer.retrieve(customer.customer_id)
      else
        ::Stripe::Customer.create(
          email: current_user.email,
          source: source,
          name: cardholder_name,
          address: cardholder_address,
          )
      end
    end

    def retrieve_payment_intent(invoice_id)
      invoice = ::Stripe::Invoice.retrieve(invoice_id)
      ::Stripe::PaymentIntent.retrieve(invoice[:payment_intent])
    end

    def retrieve_transaction(transaction)
      begin
        case transaction
        when /^sub_/
          ::Stripe::Subscription.retrieve(transaction)
        when /^in_/
          ::Stripe::Invoice.retrieve(transaction)
        end
      rescue ::Stripe::InvalidRequestError => e
        e.message
      end
    end

    def metadata_user
      { user_id: current_user.id, username: current_user.username_lower }
    end

    def transaction_ok(transaction)
      %w[active trialing paid].include?(transaction[:status])
    end
  end
end
