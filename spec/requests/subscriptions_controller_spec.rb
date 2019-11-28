# frozen_string_literal: true

require 'rails_helper'

module DiscoursePatrons
  RSpec.describe SubscriptionsController do
    context "not authenticated" do
      it "does not create a subscription" do
        ::Stripe::Plan.expects(:retrieve).never
        ::Stripe::Subscription.expects(:create).never
        post "/patrons/subscriptions.json", params: { plan: 'plan_1234', customer: 'cus_1234' }
      end
    end

    context "authenticated" do
      let(:user) { Fabricate(:user) }

      before do
        sign_in(user)
      end

      describe "create" do
        it "creates a subscription" do
          ::Stripe::Plan.expects(:retrieve).returns(
            product: 'product_12345',
            metadata: { group_name: 'awesome' }
          )

          ::Stripe::Subscription.expects(:create).with(
            customer: 'cus_1234',
            items: [ plan: 'plan_1234' ],
            metadata: { user_id: user.id, username: user.username_lower },
          ).returns(status: 'active')

          expect {
            post "/patrons/subscriptions.json", params: { plan: 'plan_1234', customer: 'cus_1234' }
          }.to change { DiscoursePatrons::Customer.count }
        end

        it "creates a customer model" do
          ::Stripe::Plan.expects(:retrieve).returns(metadata: {})
          ::Stripe::Subscription.expects(:create).returns(status: 'active')

          expect {
            post "/patrons/subscriptions.json", params: { plan: 'plan_1234', customer: 'cus_1234' }
          }.to change { DiscoursePatrons::Customer.count }
        end
      end

      describe "user groups" do
        let(:group_name) { 'group-123' }
        let(:group) { Fabricate(:group, name: group_name) }

        context "unauthorized group" do
          before do
            ::Stripe::Subscription.expects(:create).returns(status: 'active')
          end

          it "does not add the user to the admins group" do
            ::Stripe::Plan.expects(:retrieve).returns(metadata: { group_name: 'admins' })
            post "/patrons/subscriptions.json", params: { plan: 'plan_1234', customer: 'cus_1234' }
            expect(user.admin).to eq false
          end

          it "does not add the user to other group" do
            ::Stripe::Plan.expects(:retrieve).returns(metadata: { group_name: 'other' })
            post "/patrons/subscriptions.json", params: { plan: 'plan_1234', customer: 'cus_1234' }
            expect(user.groups).to be_empty
          end
        end

        context "plan has group in metadata" do
          before do
            ::Stripe::Plan.expects(:retrieve).returns(metadata: { group_name: group_name })
          end

          it "does not add the user to the group when subscription fails" do
            ::Stripe::Subscription.expects(:create).returns(status: 'failed')

            expect {
              post "/patrons/subscriptions.json", params: { plan: 'plan_1234', customer: 'cus_1234' }
            }.not_to change { group.users.count }

            expect(user.groups).to be_empty
          end

          it "adds the user to the group when the subscription is active" do
            ::Stripe::Subscription.expects(:create).returns(status: 'active')

            expect {
              post "/patrons/subscriptions.json", params: { plan: 'plan_1234', customer: 'cus_1234' }
            }.to change { group.users.count }

            expect(user.groups).not_to be_empty
          end

          it "adds the user to the group when the subscription is trialing" do
            ::Stripe::Subscription.expects(:create).returns(status: 'trialing')

            expect {
              post "/patrons/subscriptions.json", params: { plan: 'plan_1234', customer: 'cus_1234' }
            }.to change { group.users.count }

            expect(user.groups).not_to be_empty
          end
        end
      end
    end
  end
end
