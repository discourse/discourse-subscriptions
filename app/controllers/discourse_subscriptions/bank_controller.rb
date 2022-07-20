# frozen_string_literal: true

module DiscourseSubscriptions
    class BankController < ::ApplicationController
      include DiscourseSubscriptions::Stripe
      include DiscourseSubscriptions::Group
      before_action :set_api_key
      requires_login except: [:index, :contributors, :show]
  
      def index
        begin
          product_ids = Product.all.pluck(:external_id)
          products = []
  
          if product_ids.present? && is_stripe_configured?
            response = ::Stripe::Product.list({
              ids: product_ids,
              active: true
            })
  
            products = response[:data].map do |p|
              serialize_product(p)
            end
  
          end
  
          render_json_dump products
  
        rescue ::Stripe::InvalidRequestError => e
          render_json_error e.message
        end
      end
  
      def contributors
        return unless SiteSetting.discourse_subscriptions_campaign_show_contributors
        contributor_ids = Set.new
  
        campaign_product = SiteSetting.discourse_subscriptions_campaign_product
        campaign_product.present? ? contributor_ids.merge(Customer.where(product_id: campaign_product).last(5).pluck(:user_id)) : contributor_ids.merge(Customer.last(5).pluck(:user_id))
  
        contributors = ::User.where(id: contributor_ids)
  
        render_serialized(contributors, UserSerializer)
      end
  
      def show
       
      end
  
    end
  end
end
  