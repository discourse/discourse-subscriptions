# frozen_string_literal: true

module DiscoursePatrons
  module Admin
    class PlansController < ::Admin::AdminController
      include DiscoursePatrons::Stripe

      before_action :set_api_key

      def index
        begin
          plans = ::Stripe::Plan.list

          render_json_dump plans.data

        rescue ::Stripe::InvalidRequestError => e
          return render_json_error e.message
        end
      end

      def create
        begin
          plan = ::Stripe::Plan.create(
            amount: params[:amount],
            interval: params[:interval],
            product: product,
            currency: SiteSetting.discourse_patrons_currency,
          )

          render_json_dump plan

        rescue ::Stripe::InvalidRequestError => e
          return render_json_error e.message
        end
      end

      def destroy
        begin
          plan = ::Stripe::Plan.delete(params[:id])

          render_json_dump plan

        rescue ::Stripe::InvalidRequestError => e
          return render_json_error e.message
        end
      end

      private

      def product
        params[:product].slice(:id, :name).permit!.to_h.symbolize_keys if params[:product]
      end
    end
  end
end
