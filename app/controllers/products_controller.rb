# frozen_string_literal: true

module DiscoursePatrons
  class ProductsController < ::ApplicationController
    include DiscoursePatrons::Stripe

    before_action :set_api_key

    def index
      begin
        products = ::Stripe::Product.list(active: true)

        # TODO: Serialize. Remove some attributes like metadata
        render_json_dump products.data

      rescue ::Stripe::InvalidRequestError => e
        return render_json_error e.message
      end
    end
  end
end
