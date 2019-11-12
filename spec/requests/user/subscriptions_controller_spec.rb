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

      it "does not destroy a subscription" do
        ::Stripe::Subscription.expects(:delete).never
        patch "/patrons/user/subscriptions/sub_12345.json"
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

      describe "delete" do
        context "no customer record" do
          it "deletes a subscription" do
            ::Stripe::Subscription.expects(:delete).never
            delete "/patrons/user/subscriptions/sub_12345.json"
          end
        end

        context "customer exists" do
          let!(:customer) { Fabricate(:customer, customer_id: 'cus_tmp76543g', user_id: user.id) }

          it "does not delete a subscription" do
            ::Stripe::Subscription.expects(:retrieve).with('sub_12345').returns(customer: 'other')
            ::Stripe::Subscription.expects(:delete).never
            delete "/patrons/user/subscriptions/sub_12345.json"
          end

          it "deletes a subscription" do
            ::Stripe::Subscription.expects(:retrieve).with('sub_12345').returns(customer: 'cus_tmp76543g')
            ::Stripe::Subscription.expects(:delete).with('sub_12345')
            delete "/patrons/user/subscriptions/sub_12345.json"
          end
        end
      end
    end
  end
end
