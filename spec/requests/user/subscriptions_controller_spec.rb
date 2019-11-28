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
        let(:plans) do
          {
            data: [
              {
                id: "plan_1",
                product: { name: 'ACME Subscriptions' },
              },
              {
                id: "plan_2",
                product: { name: 'ACME Other Subscriptions' },
              }
            ]
          }
        end

        let(:customers) do
          {
            data: [{
              id: "cus_23456",
              subscriptions: {
                data: [
                  { id: "sub_1234", plan: { id: "plan_1" } },
                  { id: "sub_4567", plan: { id: "plan_2" } }
                ]
              },
            }]
          }
        end

        it "gets subscriptions" do
          ::Stripe::Plan.expects(:list).with(
            expand: ['data.product']
          ).returns(plans)

          ::Stripe::Customer.expects(:list).with(
            email: user.email,
            expand: ['data.subscriptions']
          ).returns(customers)

          get "/patrons/user/subscriptions.json"

          subscription = JSON.parse(response.body).first

          expect(subscription).to eq(
            "id" => "sub_1234",
            "plan" => { "id" => "plan_1" },
            "product" => { "name" => "ACME Subscriptions" }
          )
        end
      end

      describe "delete" do
        before do
          # Users can have more than one customer id
          Customer.create(user_id: user.id, customer_id: 'customer_id_1', product_id: 'p_1')
          Customer.create(user_id: user.id, customer_id: 'customer_id_2', product_id: 'p_2')
        end

        it "does not delete a subscription" do
          ::Stripe::Subscription.expects(:retrieve).with('sub_12345').returns(customer: 'wrong_id')
          ::Stripe::Subscription.expects(:delete).never

          expect {
            delete "/patrons/user/subscriptions/sub_12345.json"
          }.not_to change { DiscoursePatrons::Customer.count }

          expect(response.status).to eq 422
        end

        it "deletes the first subscription" do
          ::Stripe::Subscription.expects(:retrieve).with('sub_12345').returns(customer: 'customer_id_1')
          ::Stripe::Subscription.expects(:delete).with('sub_12345')

          expect {
            delete "/patrons/user/subscriptions/sub_12345.json"
          }.to change { DiscoursePatrons::Customer.count }.by(-1)

          expect(response.status).to eq 200
        end

        it "deletes the second subscription" do
          ::Stripe::Subscription.expects(:retrieve).with('sub_12345').returns(customer: 'customer_id_2')
          ::Stripe::Subscription.expects(:delete).with('sub_12345')

          expect {
            delete "/patrons/user/subscriptions/sub_12345.json"
          }.to change { DiscoursePatrons::Customer.count }.by(-1)

          expect(response.status).to eq 200
        end
      end
    end
  end
end
