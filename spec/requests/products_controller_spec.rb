# frozen_string_literal: true

require 'rails_helper'

module DiscoursePatrons
  RSpec.describe ProductsController do
    let(:product) do
      {
        id: "prodct_23456",
        name: "Very Special Product",
        metadata: {
          description: "Many people listened to my phone call with the Ukrainian President while it was being made"
        },
        otherstuff: true,
      }
    end

    describe "index" do
      it "gets products" do
        ::Stripe::Product.expects(:list).with(active: true).returns(data: [product])

        get "/patrons/products.json"

        expect(JSON.parse(response.body)).to eq([{
          "id" => "prodct_23456",
          "name" => "Very Special Product",
          "description" => "Many people listened to my phone call with the Ukrainian President while it was being made"
        }])
      end
    end

    describe 'show' do
      it 'retrieves the product' do
        ::Stripe::Product.expects(:retrieve).with('prod_walterwhite').returns(product)
        get "/patrons/products/prod_walterwhite.json"

        expect(JSON.parse(response.body)).to eq(
          "id" => "prodct_23456",
          "name" => "Very Special Product",
          "description" => "Many people listened to my phone call with the Ukrainian President while it was being made"
        )
      end
    end
  end
end
