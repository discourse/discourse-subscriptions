# frozen_string_literal: true

module DiscoursePatrons
  module Admin
    class ProductsController < ::Admin::AdminController
      include DiscoursePatrons::Stripe

      before_action :set_api_key

      def index
        begin
          products = ::Stripe::Product.list

          render_json_dump products.data
        rescue ::Stripe::InvalidRequestError => e
          return render_json_error e.message
        end
      end

      def create
        begin
          product = ::Stripe::Product.create(
            type: 'service',
            name: params[:name],
            active: params[:active],
            metadata: metadata
          )

          render_json_dump product

        rescue ::Stripe::InvalidRequestError => e
          return render_json_error e.message
        end
      end

      def show
        begin
          product = ::Stripe::Product.retrieve(params[:id])

          render_json_dump product

        rescue ::Stripe::InvalidRequestError => e
          return render_json_error e.message
        end
      end

      def update
        begin
          product = ::Stripe::Product.update(
            params[:id],
            name: params[:name],
            active: params[:active],
            metadata: metadata
          )

          render_json_dump product

        rescue ::Stripe::InvalidRequestError => e
          return render_json_error e.message
        end
      end

      def destroy
        begin
          product = ::Stripe::Product.delete(params[:id])

          render_json_dump product

        rescue ::Stripe::InvalidRequestError => e
          return render_json_error e.message
        end
      end

      private

      def metadata
        { group_name: params[:metadata][:group_name] }
      end
    end
  end
end
