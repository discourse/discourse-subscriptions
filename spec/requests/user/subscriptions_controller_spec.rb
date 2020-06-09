# frozen_string_literal: true

require 'rails_helper'

module DiscourseSubscriptions
  RSpec.describe User::SubscriptionsController do
    it 'is a subclass of ApplicationController' do
      expect(DiscourseSubscriptions::User::SubscriptionsController < ::ApplicationController).to eq(true)
    end

    context "not authenticated" do
      it "does not get the subscriptions" do
        ::Stripe::Customer.expects(:list).never
        get "/s/user/subscriptions.json"
      end

      it "does not destroy a subscription" do
        ::Stripe::Subscription.expects(:delete).never
        patch "/s/user/subscriptions/sub_12345.json"
      end
    end

    context "authenticated" do
      let(:user) { Fabricate(:user, email: 'beanie@example.com') }
      let(:customer) { Fabricate(:customer, user_id: user.id, customer_id: "cus_23456", product_id: "prod_123") }

      before do
        sign_in(user)
        Fabricate(:subscription, customer_id: customer.id, external_id: "sub_1234")
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
            expand: ['data.product'],
            limit: 100
          ).returns(plans)

          ::Stripe::Customer.expects(:list).with(
            email: user.email,
            expand: ['data.subscriptions']
          ).returns(customers)

          get "/s/user/subscriptions.json"

          subscription = response.parsed_body.first

          expect(subscription).to eq(
            "id" => "sub_1234",
            "plan" => { "id" => "plan_1" },
            "product" => { "name" => "ACME Subscriptions" }
          )
        end
      end

      describe "delete" do
        let(:group) { Fabricate(:group, name: 'subscribers') }

        before do
          # Users can have more than one customer id
          Customer.create(user_id: user.id, customer_id: 'customer_id_1', product_id: 'p_1')
          Customer.create(user_id: user.id, customer_id: 'customer_id_1', product_id: 'p_2')
          Customer.create(user_id: user.id, customer_id: 'customer_id_2', product_id: 'p_2')

          group.add(user)
        end

        it "does not delete a subscription when the customer is wrong" do
          ::Stripe::Subscription
            .expects(:retrieve)
            .with('sub_12345')
            .returns(
              plan: { product: 'p_1' },
              customer: 'wrong_id'
            )

          ::Stripe::Subscription
            .expects(:delete)
            .never

          expect {
            delete "/s/user/subscriptions/sub_12345.json"
          }.not_to change { DiscourseSubscriptions::Customer.count }

          expect(response.status).to eq 422
        end

        it "does not deletes the subscription when the product is wrong" do
          ::Stripe::Subscription
            .expects(:retrieve)
            .with('sub_12345')
            .returns(
              plan: { product: 'p_wrong' },
              customer: 'customer_id_2'
            )

          ::Stripe::Subscription
            .expects(:delete)
            .never

          expect {
            delete "/s/user/subscriptions/sub_12345.json"
          }.not_to change { DiscourseSubscriptions::Customer.count }

          expect(response.status).to eq 422
        end

        it "removes the user from the group" do
          ::Stripe::Subscription
            .expects(:retrieve)
            .with('sub_12345')
            .returns(
              plan: { product: 'p_1', metadata: { group_name: 'subscribers' } },
              customer: 'customer_id_1'
            )

          ::Stripe::Subscription
            .expects(:delete)

          expect {
            delete "/s/user/subscriptions/sub_12345.json"
          }.to change { user.groups.count }.by(-1)
        end

        it "does not remove the user from the group" do
          ::Stripe::Subscription
            .expects(:retrieve)
            .with('sub_12345')
            .returns(
              plan: { product: 'p_1', metadata: { group_name: 'does_not_exist' } },
              customer: 'customer_id_1'
            )

          ::Stripe::Subscription
            .expects(:delete)

          expect {
            delete "/s/user/subscriptions/sub_12345.json"
          }.not_to change { user.groups.count }
        end

        it "deletes the first subscription product 1" do
          ::Stripe::Subscription
            .expects(:retrieve)
            .with('sub_12345')
            .returns(
              plan: { product: 'p_1', metadata: {} },
              customer: 'customer_id_1'
            )

          ::Stripe::Subscription
            .expects(:delete)
            .with('sub_12345')

          expect {
            delete "/s/user/subscriptions/sub_12345.json"
          }.to change { DiscourseSubscriptions::Customer.count }.by(-1)

          expect(response.status).to eq 200
        end

        it "deletes the first subscription product 2" do
          ::Stripe::Subscription
            .expects(:retrieve)
            .with('sub_12345')
            .returns(
              plan: { product: 'p_2', metadata: {} },
              customer: 'customer_id_1'
            )

          ::Stripe::Subscription
            .expects(:delete)
            .with('sub_12345')

          expect {
            delete "/s/user/subscriptions/sub_12345.json"
          }.to change { DiscourseSubscriptions::Customer.count }.by(-1)

          expect(response.status).to eq 200
        end

        it "deletes the second subscription" do
          ::Stripe::Subscription
            .expects(:retrieve)
            .with('sub_12345')
            .returns(
              plan: { product: 'p_2', metadata: {} },
              customer: 'customer_id_2'
            )

          ::Stripe::Subscription
            .expects(:delete)
            .with('sub_12345')

          expect {
            delete "/s/user/subscriptions/sub_12345.json"
          }.to change { DiscourseSubscriptions::Customer.count }.by(-1)

          expect(response.status).to eq 200
        end
      end
    end
  end
end
