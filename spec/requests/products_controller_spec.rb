# frozen_string_literal: true

require 'rails_helper'

module DiscourseSubscriptions
  RSpec.describe ProductsController do
    describe "products" do
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
      let(:product_ids) { ["prodct_23456"] }

      before do
        Fabricate(:product, external_id: "prodct_23456")
      end

      context "unauthenticated" do
        it "gets products" do
          ::Stripe::Product.expects(:list).with(ids: product_ids, active: true).returns(data: [product])

          get "/s/products.json"

          expect(response.parsed_body).to eq([{
            "id" => "prodct_23456",
            "name" => "Very Special Product",
            "description" => "Many people listened to my phone call with the Ukrainian President while it was being made",
            "subscribed" => false
          }])
        end
      end

      context "authenticated" do
        let(:user) { Fabricate(:user) }

        before do
          sign_in(user)
        end

        describe "index" do
          it "gets products" do
            ::Stripe::Product.expects(:list).with(ids: product_ids, active: true).returns(data: [product])

            get "/s/products.json"

            expect(response.parsed_body).to eq([{
              "id" => "prodct_23456",
              "name" => "Very Special Product",
              "description" => "Many people listened to my phone call with the Ukrainian President while it was being made",
              "subscribed" => false
            }])
          end

          it "is subscribed" do
            Fabricate(:customer, product_id: product[:id], user_id: user.id, customer_id: 'x')
            ::Stripe::Product.expects(:list).with(ids: product_ids, active: true).returns(data: [product])

            get "/s/products.json"
            data = response.parsed_body
            expect(data.first["subscribed"]).to eq true
          end

          it "is not subscribed" do
            ::DiscourseSubscriptions::Customer.delete_all
            ::Stripe::Product.expects(:list).with(ids: product_ids, active: true).returns(data: [product])

            get "/s/products.json"
            data = response.parsed_body
            expect(data.first["subscribed"]).to eq false
          end
        end

        describe 'show' do
          it 'retrieves the product' do
            ::Stripe::Product.expects(:retrieve).with('prod_walterwhite').returns(product)
            get "/s/products/prod_walterwhite.json"

            expect(response.parsed_body).to eq(
              "id" => "prodct_23456",
              "name" => "Very Special Product",
              "description" => "Many people listened to my phone call with the Ukrainian President while it was being made",
              "subscribed" => false
            )
          end
        end
      end
    end
  end
end
