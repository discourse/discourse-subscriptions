# frozen_string_literal: true

module DiscoursePatrons
  module Admin
    class ProductsController < ::Admin::AdminController
      include DiscoursePatrons::Stripe

      before_action :set_api_key

      def index
        products = ::Stripe::Product.list
        render_json_dump products.data
      end

      def create
        begin
          product = ::Stripe::Product.create(
            type: 'service',
            name: params[:name],
            active: params[:active],
            metadata: {
              group_name: params[:groupName]
            }
          )

          render_json_dump product

        rescue ::Stripe::InvalidRequestError => e
          return render_json_error e.message
        end
      end
    end
  end
end
