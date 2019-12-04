# frozen_string_literal: true

module DiscourseSubscriptions
  module Admin
    class PlansController < ::Admin::AdminController
      include DiscourseSubscriptions::Stripe

      before_action :set_api_key

      def index
        begin
          plans = ::Stripe::Plan.list(product_params)

          render_json_dump plans.data

        rescue ::Stripe::InvalidRequestError => e
          return render_json_error e.message
        end
      end

      def create
        begin
          plan = ::Stripe::Plan.create(
            nickname: params[:nickname],
            amount: params[:amount],
            interval: params[:interval],
            product: params[:product],
            trial_period_days: params[:trial_period_days],
            currency: params[:currency],
            active: params[:active],
            metadata: { group_name: params[:metadata][:group_name] }
          )

          render_json_dump plan

        rescue ::Stripe::InvalidRequestError => e
          return render_json_error e.message
        end
      end

      def show
        begin
          plan = ::Stripe::Plan.retrieve(params[:id])

          serialized = plan.to_h.merge(currency: plan[:currency].upcase)

          render_json_dump serialized

        rescue ::Stripe::InvalidRequestError => e
          return render_json_error e.message
        end
      end

      def update
        begin
          plan = ::Stripe::Plan.update(
            params[:id],
            nickname: params[:nickname],
            trial_period_days: params[:trial_period_days],
            active: params[:active],
            metadata: { group_name: params[:metadata][:group_name] }
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

      def product_params
        { product: params[:product_id] } if params[:product_id]
      end
    end
  end
end
