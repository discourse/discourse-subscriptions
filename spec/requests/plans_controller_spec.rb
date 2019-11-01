# frozen_string_literal: true

require 'rails_helper'

module DiscoursePatrons
  RSpec.describe PlansController do
    describe "index" do
      it "lists the active plans" do
        ::Stripe::Plan.expects(:list).with(active: true)
        get "/patrons/plans.json"
      end

      it "orders and serialises the plans" do
        ::Stripe::Plan.expects(:list).returns(
          data: [
            { id: 'plan_id123', amount: 1220, currency: 'aud', interval: 'year', metadata: {} },
            { id: 'plan_id234', amount: 1399, currency: 'usd', interval: 'year', metadata: {} },
            { id: 'plan_id678', amount: 1000, currency: 'aud', interval: 'week', metadata: {} }
          ]
        )

        get "/patrons/plans.json"

        expect(JSON.parse(response.body)).to eq([
          { "amount" => 1000, "currency" => "aud", "id" => "plan_id678", "interval" => "week" },
          { "amount" => 1220, "currency" => "aud", "id" => "plan_id123", "interval" => "year" },
          { "amount" => 1399, "currency" => "usd", "id" => "plan_id234", "interval" => "year" }
        ])
      end
    end
  end
end
