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
    end
  end
end
