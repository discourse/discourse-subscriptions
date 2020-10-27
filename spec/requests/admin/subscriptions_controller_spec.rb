# frozen_string_literal: true

require 'rails_helper'

module DiscourseSubscriptions
  RSpec.describe Admin::SubscriptionsController do
    it 'is a subclass of AdminController' do
      expect(DiscourseSubscriptions::Admin::SubscriptionsController < ::Admin::AdminController).to eq(true)
    end

    let(:user) { Fabricate(:user) }
    let(:customer) { Fabricate(:customer, user_id: user.id, customer_id: 'c_123', product_id: 'pr_34578') }

    before do
      Fabricate(:subscription, external_id: "sub_12345", customer_id: customer.id)
    end

    context 'unauthenticated' do
      it "does nothing" do
        ::Stripe::Subscription.expects(:list).never
        get "/s/admin/subscriptions.json"
        expect(response.status).to eq(403)
      end

      it "does not destroy a subscription" do
        ::Stripe::Subscription.expects(:delete).never
        patch "/s/admin/subscriptions/sub_12345.json"
      end
    end

    context 'authenticated' do
      let(:admin) { Fabricate(:admin) }

      before { sign_in(admin) }

      describe "index" do
        it "gets the subscriptions and products" do
          SiteSetting.discourse_subscriptions_public_key = "public-key"
          SiteSetting.discourse_subscriptions_secret_key = "secret-key"
          ::Stripe::Subscription.expects(:list).with(expand: ['data.plan.product']).returns(
            [
              { id: "sub_12345" },
              { id: "sub_nope" }
            ]
          )
          get "/s/admin/subscriptions.json"
          subscriptions = response.parsed_body[0]["id"]

          expect(response.status).to eq(200)
          expect(subscriptions).to eq("sub_12345")
        end
      end

      describe "destroy" do
        let(:group) { Fabricate(:group, name: 'subscribers') }

        before do
          group.add(user)
        end

        it "deletes a customer" do
          ::Stripe::Subscription
            .expects(:delete)
            .with('sub_12345')
            .returns(
              plan: { product: 'pr_34578' },
              customer: 'c_123'
            )

          expect {
            delete "/s/admin/subscriptions/sub_12345.json"
          }.to change { DiscourseSubscriptions::Customer.count }.by(-1)
        end

        it "removes the user from the group" do
          ::Stripe::Subscription
            .expects(:delete)
            .with('sub_12345')
            .returns(
              plan: { product: 'pr_34578', metadata: { group_name: 'subscribers' } },
              customer: 'c_123'
            )

          expect {
            delete "/s/admin/subscriptions/sub_12345.json"
          }.to change { user.groups.count }.by(-1)
        end

        it "does not remove the user from the group" do
          ::Stripe::Subscription
            .expects(:delete)
            .with('sub_12345')
            .returns(
              plan: { product: 'pr_34578', metadata: { group_name: 'group_does_not_exist' } },
              customer: 'c_123'
            )

          expect {
            delete "/s/admin/subscriptions/sub_12345.json"
          }.not_to change { user.groups.count }
        end

        it "refunds if params[:refund] present" do
          ::Stripe::Subscription
            .expects(:delete)
            .with('sub_12345')
            .returns(
              plan: { product: 'pr_34578' },
              customer: 'c_123'
            )
          ::Stripe::Subscription.expects(:retrieve).with('sub_12345').returns(latest_invoice: 'in_123')
          ::Stripe::Invoice.expects(:retrieve).with('in_123').returns(payment_intent: 'pi_123')
          ::Stripe::Refund.expects(:create).with(payment_intent: 'pi_123')

          delete "/s/admin/subscriptions/sub_12345.json", params: { refund: true }
        end
      end
    end
  end
end
