# frozen_string_literal: true

require 'rails_helper'

module DiscoursePatrons
  RSpec.describe ProductsController do
    describe "index" do
      it "lists the active products" do
        ::Stripe::Product.expects(:list).with(active: true)
        get "/patrons/products.json"
      end
    end
  end
end
