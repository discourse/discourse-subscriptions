# frozen_string_literal: true

require 'rails_helper'

module DiscoursePatrons
  RSpec.describe SubscriptionsController do
    context "not authenticated" do
      it "does not get the subscriptions" do
        ::Stripe::Customer.expects(:list).never
        get "/patrons/subscriptions.json"
      end

      it "does not create a subscription" do
        ::Stripe::Plan.expects(:retrieve).never
        ::Stripe::Subscription.expects(:create).never
        post "/patrons/subscriptions.json", params: { plan: 'plan_1234', customer: 'cus_1234' }
      end

      it "does not destroy a subscription" do
        ::Stripe::Subscription.expects(:delete).never
        patch "/patrons/subscriptions/sub_12345.json"
      end
    end

    context "authenticated" do
      let(:user) { Fabricate(:user, email: 'hello.2@example.com') }

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

          get "/patrons/subscriptions.json"

          expect(JSON.parse(response.body)).to eq([{"id"=>"sub_1234"}, {"id"=>"sub_4567"}])
        end
      end

      describe "create" do
        it "creates a subscription" do
          ::Stripe::Plan.expects(:retrieve).returns(metadata: { group_name: 'awesome' })
          ::Stripe::Subscription.expects(:create).with(
            customer: 'cus_1234',
            items: [ plan: 'plan_1234' ]
          )
          post "/patrons/subscriptions.json", params: { plan: 'plan_1234', customer: 'cus_1234' }
        end

        it "creates a customer" do
          ::Stripe::Plan.expects(:retrieve).returns(metadata: {})
          ::Stripe::Subscription.expects(:create).returns(status: 'active')

          expect {
            post "/patrons/subscriptions.json", params: { plan: 'plan_1234', customer: 'cus_1234' }
          }.to change { DiscoursePatrons::Customer.count }
        end

        it "does not create a customer id one existeth" do
          ::Stripe::Plan.expects(:retrieve).returns(metadata: {})
          ::Stripe::Subscription.expects(:create).returns(status: 'active')
          DiscoursePatrons::Customer.create(user_id: user.id, customer_id: 'cus_1234')

          DiscoursePatrons::Customer.expects(:create).never
          post "/patrons/subscriptions.json", params: { plan: 'plan_1234', customer: 'cus_1234' }
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

      describe "delete" do
        it "deletes a subscription" do
          ::Stripe::Subscription.expects(:delete).with('sub_12345')
          delete "/patrons/subscriptions/sub_12345.json"
        end
      end
    end
  end
end
