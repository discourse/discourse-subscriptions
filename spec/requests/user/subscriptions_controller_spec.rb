# frozen_string_literal: true

require 'rails_helper'

module DiscoursePatrons
  RSpec.describe User::SubscriptionsController do
    it 'is a subclass of ApplicationController' do
      expect(DiscoursePatrons::User::SubscriptionsController < ::ApplicationController).to eq(true)
    end

    context "not authenticated" do
      it "does not get the subscriptions" do
        ::Stripe::Customer.expects(:list).never
        get "/patrons/user/subscriptions.json"
      end
    end

    context "authenticated" do
      let(:user) { Fabricate(:user, email: 'beanie@example.com') }

      before do
        sign_in(user)
      end

      describe "index" do
        let(:customers) do
          {
            data: [{
              id: "cus_23456",
              subscriptions: {
                data: [{ id: "sub_1234" }, { id: "sub_4567" }]
              },
            }]
          }
        end

        it "gets subscriptions" do
          ::Stripe::Customer.expects(:list).with(
            email: user.email,
            expand: ['data.subscriptions']
          ).returns(customers)

          get "/patrons/user/subscriptions.json"

          expect(JSON.parse(response.body)).to eq([{ "id" => "sub_1234" }, { "id" => "sub_4567" }])
        end
      end
    end
  end
end
