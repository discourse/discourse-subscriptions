# frozen_string_literal: true

module DiscourseSubscriptions
  module Admin
    class ProductsController < ::Admin::AdminController
      include DiscourseSubscriptions::Stripe

      before_action :set_api_key

      def index
        begin
          products = ::Stripe::Product.list

          render_json_dump products.data
        rescue ::Stripe::InvalidRequestError => e
          render_json_error e.message
        end
      end

      def create
        begin
          create_params = product_params.merge!(type: 'service')

          if params[:statement_descriptor].blank?
            create_params.except!(:statement_descriptor)
          end

          product = ::Stripe::Product.create(create_params)

          render_json_dump product

        rescue ::Stripe::InvalidRequestError => e
          render_json_error e.message
        end
      end

      def show
        begin
          product = ::Stripe::Product.retrieve(params[:id])

          render_json_dump product

        rescue ::Stripe::InvalidRequestError => e
          render_json_error e.message
        end
      end

      def update
        begin
          product = ::Stripe::Product.update(
            params[:id],
            product_params
          )

          render_json_dump product

        rescue ::Stripe::InvalidRequestError => e
          render_json_error e.message
        end
      end

      def destroy
        begin
          product = ::Stripe::Product.delete(params[:id])

          render_json_dump product

        rescue ::Stripe::InvalidRequestError => e
          render_json_error e.message
        end
      end

      private

      def product_params
        params.permit!

        {
          name: params[:name],
          active: params[:active],
          statement_descriptor: params[:statement_descriptor],
          metadata: { description: params.dig(:metadata, :description) }
        }
      end
    end
  end
end
