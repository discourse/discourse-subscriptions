# frozen_string_literal: true

require 'rails_helper'

module DiscoursePatrons
  RSpec.describe SubscriptionsController do
    context "authenticated" do
      let(:user) { Fabricate(:user, email: 'hello.2@example.com') }

      before do
        sign_in(user)
      end

      describe "create" do
        it "creates a subscription with a customer" do
          ::Stripe::Subscription.expects(:create).with(has_entry(customer: 'cus_1234'))
          post "/patrons/subscriptions.json", params: { customer: 'cus_1234' }
        end

        it "creates a subscription with a plan" do
          ::Stripe::Subscription.expects(:create).with(has_entry(items: [ plan: 'plan_1234' ]))
          post "/patrons/subscriptions.json", params: { plan: 'plan_1234' }
        end
      end

      describe "user groups" do
        let(:group) { Fabricate(:group, name: 'group-123') }

        it "does not add the user to the group" do
          ::Stripe::Subscription.expects(:create).returns(status: 'failed')

          expect {
            post "/patrons/subscriptions.json", params: { plan: 'plan_1234' }
          }.not_to change { group.users.count }
        end

        it "adds the user to the group when the subscription is active" do
          ::Stripe::Subscription.expects(:create).returns(status: 'active')

          expect {
            post "/patrons/subscriptions.json", params: { plan: 'plan_1234' }
          }.to change { group.users.count }
        end

        it "adds the user to the group when the subscription is trialing" do
          ::Stripe::Subscription.expects(:create).returns(status: 'trialing')

          expect {
            post "/patrons/subscriptions.json", params: { plan: 'plan_1234' }
          }.to change { group.users.count }
        end
      end
    end
  end
end
