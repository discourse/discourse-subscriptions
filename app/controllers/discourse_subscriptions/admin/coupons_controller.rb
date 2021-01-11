# frozen_string_literal: true

module DiscourseSubscriptions
  module Admin
    class CouponsController < ::Admin::AdminController
      include DiscourseSubscriptions::Stripe
      include DiscourseSubscriptions::Group
      before_action :set_api_key

      def index
        begin
          promo_codes = ::Stripe::PromotionCode.list({ limit: 100 })[:data]
          render_json_dump promo_codes
        rescue ::Stripe::InvalidRequestError => e
          render_json_error e.message
        end
      end

      def destroy
        params.require(:id)
        begin
        rescue ::Stripe::InvalidRequestError => e
          render_json_error e.message
        end
      end
    end
  end
end
