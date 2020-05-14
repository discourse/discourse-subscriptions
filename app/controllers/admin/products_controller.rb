# frozen_string_literal: true

module DiscourseSubscriptions
  module Admin
    class ProductsController < ::Admin::AdminController
      include DiscourseSubscriptions::Stripe

      before_action :set_api_key

      def index
        begin
          product_ids = Product.all.pluck(:external_id)
          products = []

          if product_ids.present?
            products = ::Stripe::Product.list({ ids: product_ids }) 
            products = products[:data]
          end

          render_json_dump products
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

          Product.create(
            external_id: product[:id]
          )

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
          external_product = ::Stripe::Product.delete(params[:id])

          product = Product.find_by(external_id: params[:id])

          product.delete if product

          render_json_dump external_product

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
