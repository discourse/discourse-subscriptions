# frozen_string_literal: true

require 'rails_helper'

module DiscoursePatrons
  RSpec.describe Admin::SubscriptionsController do
    it 'is a subclass of AdminController' do
      expect(DiscoursePatrons::Admin::SubscriptionsController < ::Admin::AdminController).to eq(true)
    end

    context 'unauthenticated' do
      it "does nothing" do
        ::Stripe::Subscription.expects(:list).never
        get "/patrons/admin/subscriptions.json"
        expect(response.status).to eq(403)
      end

      it "does not destroy a subscription" do
        ::Stripe::Subscription.expects(:delete).never
        patch "/patrons/admin/subscriptions/sub_12345.json"
      end
    end

    context 'authenticated' do
      let(:user) { Fabricate(:user) }
      let(:admin) { Fabricate(:admin) }

      before { sign_in(admin) }

      describe "index" do
        it "gets the subscriptions and products" do
          ::Stripe::Subscription.expects(:list).with(expand: ['data.plan.product'])
          get "/patrons/admin/subscriptions.json"
          expect(response.status).to eq(200)
        end
      end

      describe "destroy" do
        let(:group) { Fabricate(:group, name: 'subscribers') }

        before do
          DiscoursePatrons::Customer.create(
            user_id: user.id,
            customer_id: 'c_123',
            product_id: 'pr_34578'
          )

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
            delete "/patrons/admin/subscriptions/sub_12345.json"
          }.to change { DiscoursePatrons::Customer.count }.by(-1)
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
            delete "/patrons/admin/subscriptions/sub_12345.json"
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
            delete "/patrons/admin/subscriptions/sub_12345.json"
          }.not_to change { user.groups.count }
        end
      end
    end
  end
end
