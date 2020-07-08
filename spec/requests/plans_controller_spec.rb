# frozen_string_literal: true

require 'rails_helper'

module DiscourseSubscriptions
  RSpec.describe PlansController do
    let(:user) { Fabricate(:user) }

    before do
      sign_in(user)
    end

    describe "index" do
      it "lists the active plans" do
        ::Stripe::Price.expects(:list).with(active: true)
        get "/s/plans.json"
      end

      it "lists the active plans for a product" do
        ::Stripe::Price.expects(:list).with(active: true, product: 'prod_3765')
        get "/s/plans.json", params: { product_id: 'prod_3765' }
      end

      it "orders and serialises the plans" do
        ::Stripe::Price.expects(:list).returns(
          data: [
            { id: 'plan_id123', unit_amount: 1220, currency: 'aud', recurring: { interval: 'year' }, metadata: {} },
            { id: 'plan_id234', unit_amount: 1399, currency: 'usd', recurring: { interval: 'year' }, metadata: {} },
            { id: 'plan_id678', unit_amount: 1000, currency: 'aud', recurring: { interval: 'week' }, metadata: {} }
          ]
        )

        get "/s/plans.json"

        expect(response.parsed_body).to eq([
          { "currency" => "aud", "id" => "plan_id123", "recurring" => { "interval" => "year" }, "unit_amount" => 1220 },
          { "currency" => "usd", "id" => "plan_id234", "recurring" => { "interval" => "year" }, "unit_amount" => 1399 },
          { "currency" => "aud", "id" => "plan_id678", "recurring" => { "interval" => "week" }, "unit_amount" => 1000 }
        ])
      end
    end
  end
end
