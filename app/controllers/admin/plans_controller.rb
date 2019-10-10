# frozen_string_literal: true

module DiscoursePatrons
  module Admin
    class PlansController < ::Admin::AdminController
      include DiscoursePatrons::Stripe

      before_action :set_api_key

      def index
        plans = ::Stripe::Plan.list
        render json: plans.data
      end

      def create
        begin

          plan = ::Stripe::Plan.create(
            amount: params[:amount],
            interval: params[:interval],
            product: { name: params[:name] },
            currency: SiteSetting.discourse_patrons_currency,
            id: plan_id,
          )

          render_json_dump plan

        rescue ::Stripe::InvalidRequestError => e
          return render_json_error e.message
        end
      end

      def destroy
        plan = ::Stripe::Plan.delete(params[:id])
        render json: plan
      end

      private

      def plan_id
        params[:name].parameterize.dasherize if params[:name]
      end
    end
  end
end
