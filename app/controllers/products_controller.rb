# frozen_string_literal: true

module DiscoursePatrons
  class ProductsController < ::ApplicationController
    include DiscoursePatrons::Stripe

    before_action :set_api_key

    def index
      begin
        response = ::Stripe::Product.list(active: true)

        products = response[:data].map do |p|
          serialize(p)
        end

        render_json_dump products

      rescue ::Stripe::InvalidRequestError => e
        return render_json_error e.message
      end
    end

    def show
      begin
        product = ::Stripe::Product.retrieve(params[:id])

        render_json_dump serialize(product)

      rescue ::Stripe::InvalidRequestError => e
        return render_json_error e.message
      end
    end

    private

    def serialize(product)
      {
        id: product[:id],
        name: product[:name],
        description: product[:metadata][:description]
      }
    end
  end
end
