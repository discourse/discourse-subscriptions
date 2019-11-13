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
      let(:admin) { Fabricate(:admin) }

      before { sign_in(admin) }

      describe "index" do
        it "gets the subscriptions" do
          ::Stripe::Subscription.expects(:list)
          get "/patrons/admin/subscriptions.json"
          expect(response.status).to eq(200)
        end
      end

      describe "destroy" do
        it "deletes a subscription" do
          ::Stripe::Subscription.expects(:delete).with('sub_12345')
          delete "/patrons/admin/subscriptions/sub_12345.json"
        end
      end
    end
  end
end
