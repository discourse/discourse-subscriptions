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
          promo_codes = promo_codes.select { |code| code[:coupon][:valid] == true }
          render_json_dump promo_codes
        rescue ::Stripe::InvalidRequestError => e
          render_json_error e.message
        end
      end

      def create
        params.require([:promo, :discount_type, :discount, :active])
        begin
          coupon_params = {
            duration: 'forever',
          }

          case params[:discount_type]
          when 'amount'
            coupon_params[:amount_off] = params[:discount].to_i * 100
            coupon_params[:currency] = SiteSetting.discourse_subscriptions_currency
          when 'percent'
            coupon_params[:percent_off] = params[:discount]
          end

          coupon = ::Stripe::Coupon.create(coupon_params)

          promo_code = ::Stripe::PromotionCode.create({ coupon: coupon[:id], code: params[:promo] }) if coupon.present?

          render_json_dump promo_code
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
