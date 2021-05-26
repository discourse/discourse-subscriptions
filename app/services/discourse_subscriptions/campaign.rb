# frozen_string_literal: true

module DiscourseSubscriptions
  class Campaign
    include DiscourseSubscriptions::Stripe

    def initialize
      set_api_key # instantiates Stripe API
    end

    def refresh_data
      product_ids = Product.all.pluck(:external_id)
      amount = 0
      subscriptions = get_subscription_data
      subscriptions = filter_to_subscriptions_products(subscriptions, product_ids)

      # get number of subscribers
      SiteSetting.discourse_subscriptions_campaign_subscribers = subscriptions.length

      # calculate amount raised
      subscriptions.map do |sub|
        sub_amount = calculate_monthly_amount(sub)
        amount += sub_amount
      end

      SiteSetting.discourse_subscriptions_campaign_amount_raised = amount

      if SiteSetting.discourse_subscriptions_campaign_show_contributors == true
        contributor_ids = Customer.last(5).pluck(:user_id)
        usernames = contributor_ids.map { |id| ::User.find(id).username }
        SiteSetting.discourse_subscriptions_campaign_contributors = usernames.join(",") || ""
      else
        SiteSetting.discourse_subscriptions_campaign_contributors = ""
      end
    end

    def create_campaign
      begin
        group = create_campaign_group
        product = create_campaign_product
        create_campaign_prices(product, group)

        SiteSetting.discourse_subscriptions_campaign_enabled = true
        SiteSetting.discourse_subscriptions_campaign_product = product[:id]
      rescue ::Stripe::InvalidRequestError => e
        e
      end
    end

    protected

    def create_campaign_group
      return if ::Group.find_by(name: I18n.t('js.discourse_subscriptions.campaign.supporters'))

      # since this is public, we want to localize this as much as possible
      group = ::Group.create(name: I18n.t('js.discourse_subscriptions.campaign.supporters'))

      params = {
        full_name: I18n.t('js.discourse_subscriptions.campaign.supporters'),
        title: I18n.t('js.discourse_subscriptions.campaign.supporter'),
        flair_icon: "donate"
      }

      group.update(params)

      group[:name]
    end

    def create_campaign_product
      # fill out params
      product_params = {
        name: I18n.t('js.discourse_subscriptions.campaign.title'),
        active: true,
        metadata: {
          description: I18n.t('js.discourse_subscriptions.campaign.body'),
        }
      }

      product = ::Stripe::Product.create(product_params)

      Product.create(external_id: product[:id])

      product
    end

    def create_campaign_prices(product, group)
      # hard coded defaults to make setting this up as simple as possible
      monthly_prices = [3, 5, 10, 25]
      yearly_prices = [50, 100]

      monthly_prices.each do |price|
        create_price(product[:id], group, price, "month")
      end

      yearly_prices.each do |price|
        create_price(product[:id], group, price, "year")
      end
    end

    def create_price(product_id, group_name, amount, recurrence)
      price_object = {
        nickname: "#{amount}/#{recurrence}",
        unit_amount: amount * 100,
        product: product_id,
        currency: SiteSetting.discourse_subscriptions_currency,
        active: true,
        recurring: {
          interval: recurrence
        },
        metadata: {
          group_name: group_name
        }
      }

      plan = ::Stripe::Price.create(price_object)
    end

    def get_subscription_data
      subscriptions = []
      current_set = {
        has_more: true,
        last_record: nil
      }

      until current_set[:has_more] == false
        current_set = ::Stripe::Subscription.list(
          expand: ['data.plan.product'],
          limit: 100,
          starting_after: current_set[:last_record]
        )

        current_set[:last_record] = current_set[:data].last[:id] if current_set[:data].present?
        subscriptions.concat(current_set[:data].to_a)
      end

      subscriptions
    end

    def filter_to_subscriptions_products(data, ids)
      valid = data.select do |sub|
        # cannot .dig stripe objects
        items = sub[:items][:data][0] if sub[:items] && sub[:items][:data]
        product = items[:price][:product] if items[:price] && items[:price][:product]

        ids.include?(product)
      end
      valid.empty? ? nil : valid
    end

    def calculate_monthly_amount(sub)
      items = sub[:items][:data][0] if sub[:items] && sub[:items][:data]
      price = items[:price] if items[:price]
      unit_amount = price[:unit_amount] if price[:unit_amount]
      recurrence = price[:recurring][:interval] if price[:recurring] && price[:recurring][:interval]

      case recurrence
      when "day"
        unit_amount = unit_amount * 30
      when "week"
        unit_amount = unit_amount * 4
      when "year"
        unit_amount = unit_amount / 12
      end

      unit_amount
    end
  end
end
