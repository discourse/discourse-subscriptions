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
    end

    context 'authenticated' do
      let(:admin) { Fabricate(:admin) }

      before { sign_in(admin) }

      it "gets the empty subscriptions" do
        ::Stripe::Subscription.expects(:list)
        get "/patrons/admin/subscriptions.json"
        expect(response.status).to eq(200)
      end
    end
  end
end
