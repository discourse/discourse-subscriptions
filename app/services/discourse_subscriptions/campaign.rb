# frozen_string_literal: true

module DiscourseSubscriptions
  class Campaign
    include DiscourseSubscriptions::Stripe

    def initialize
      @subscribers = 0
      @amount = 0
      set_api_key # instantiates Stripe API
    end

    def self.subscribers
      @subscribers
    end

    def self.amount_raised
      @amount
    end

    def refresh_data
      product_ids = Product.all.pluck(:external_id)
      subscriptions = get_subscription_data
      subscriptions = filter_to_subscription_products(subscriptions, product_ids)

      # get number of subscribers
      @subscribers = subscriptions.length

      # calculate amount raised
      subscriptions.map do |sub|
        items = sub[:items][:data][0] if sub[:items] && sub[:items][:data]
        unit_amount = items[:price][:unit_amount] if items[:price] && items[:price][:unit_amount]
        @amount += unit_amount
      end
      @amount = @amount / 100
    end

    private

    def get_subscription_data
      subscriptions = []
      current_set = {
        has_more: true
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
  end
end
