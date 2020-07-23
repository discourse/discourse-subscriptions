# frozen_string_literal: true

require 'rails_helper'

module DiscourseSubscriptions
  RSpec.describe SubscriptionsController do
    context "not authenticated" do
      it "does not create a subscription" do
        ::Stripe::Price.expects(:retrieve).never
        ::Stripe::Subscription.expects(:create).never
        post "/s/subscriptions.json", params: { plan: 'plan_1234', customer: 'cus_1234' }
      end
    end

    context "authenticated" do
      let(:user) { Fabricate(:user) }

      before do
        sign_in(user)
      end

      describe "create" do
        it "creates a subscription" do
          ::Stripe::Price.expects(:retrieve).returns(
            type: 'recurring',
            product: 'product_12345',
            metadata: {
              group_name: 'awesome',
              trial_period_days: 0
            }
          )

          ::Stripe::Subscription.expects(:create).with(
            customer: 'cus_1234',
            items: [ price: 'plan_1234' ],
            metadata: { user_id: user.id, username: user.username_lower },
            trial_period_days: 0
          ).returns(status: 'active', customer: 'cus_1234')

          expect {
            post "/s/subscriptions.json", params: { plan: 'plan_1234', customer: 'cus_1234' }
          }.to change { DiscourseSubscriptions::Customer.count }
        end

        it "creates a one time payment subscription" do
          ::Stripe::Price.expects(:retrieve).returns(
            type: 'one_time',
            product: 'product_12345',
            metadata: {
              group_name: 'awesome'
            }
          )

          ::Stripe::InvoiceItem.expects(:create)

          ::Stripe::Invoice.expects(:create).returns(status: 'open', id: 'in_123')

          ::Stripe::Invoice.expects(:finalize_invoice).returns(id: 'in_123', status: 'open', payment_intent: 'pi_123')

          ::Stripe::Invoice.expects(:retrieve).returns(id: 'in_123', status: 'open', payment_intent: 'pi_123')

          ::Stripe::PaymentIntent.expects(:retrieve).returns(status: 'successful')

          ::Stripe::Invoice.expects(:pay).returns(status: 'paid', customer: 'cus_1234')

          expect {
            post '/s/subscriptions.json', params: { plan: 'plan_1234', customer: 'cus_1234' }
          }.to change { DiscourseSubscriptions::Customer.count }

        end

        it "creates a customer model" do
          ::Stripe::Price.expects(:retrieve).returns(type: 'recurring', metadata: {})
          ::Stripe::Subscription.expects(:create).returns(status: 'active', customer: 'cus_1234')

          expect {
            post "/s/subscriptions.json", params: { plan: 'plan_1234', customer: 'cus_1234' }
          }.to change { DiscourseSubscriptions::Customer.count }
        end
      end

      describe "strong customer authenticated transaction" do
        context "with subscription" do
          it "finalizes the subscription" do
            ::Stripe::Price.expects(:retrieve).returns(id: "plan_1234", product: "prod_1234", metadata: {})
            ::Stripe::Subscription.expects(:retrieve).returns(id: "sub_123", customer: 'cus_1234', status: "active")

            expect {
              post "/s/subscriptions/finalize.json", params: { plan: 'plan_1234', transaction: 'sub_1234' }
            }.to change { DiscourseSubscriptions::Customer.count }
          end
        end

        context "with one-time payment" do
          it "finalizes the one-time payment" do
            ::Stripe::Price.expects(:retrieve).returns(id: "plan_1234", product: "prod_1234", metadata: {})
            ::Stripe::Invoice.expects(:retrieve).returns(id: "in_123", customer: 'cus_1234', status: "paid")

            expect {
              post "/s/subscriptions/finalize.json", params: { plan: 'plan_1234', transaction: 'in_1234' }
            }.to change { DiscourseSubscriptions::Customer.count }
          end
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
            ::Stripe::Price.expects(:retrieve).returns(type: 'recurring', metadata: { group_name: 'admins' })
            post "/s/subscriptions.json", params: { plan: 'plan_1234', customer: 'cus_1234' }
            expect(user.admin).to eq false
          end

          it "does not add the user to other group" do
            ::Stripe::Price.expects(:retrieve).returns(type: 'recurring', metadata: { group_name: 'other' })
            post "/s/subscriptions.json", params: { plan: 'plan_1234', customer: 'cus_1234' }
            expect(user.groups).to be_empty
          end
        end

        context "plan has group in metadata" do
          before do
            ::Stripe::Price.expects(:retrieve).returns(type: 'recurring', metadata: { group_name: group_name })
          end

          it "does not add the user to the group when subscription fails" do
            ::Stripe::Subscription.expects(:create).returns(status: 'failed')

            expect {
              post "/s/subscriptions.json", params: { plan: 'plan_1234', customer: 'cus_1234' }
            }.not_to change { group.users.count }

            expect(user.groups).to be_empty
          end

          it "adds the user to the group when the subscription is active" do
            ::Stripe::Subscription.expects(:create).returns(status: 'active')

            expect {
              post "/s/subscriptions.json", params: { plan: 'plan_1234', customer: 'cus_1234' }
            }.to change { group.users.count }

            expect(user.groups).not_to be_empty
          end

          it "adds the user to the group when the subscription is trialing" do
            ::Stripe::Subscription.expects(:create).returns(status: 'trialing')

            expect {
              post "/s/subscriptions.json", params: { plan: 'plan_1234', customer: 'cus_1234' }
            }.to change { group.users.count }

            expect(user.groups).not_to be_empty
          end
        end
      end
    end
  end
end
