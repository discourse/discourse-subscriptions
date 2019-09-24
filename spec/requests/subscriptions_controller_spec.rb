# frozen_string_literal: true

require 'rails_helper'

module DiscoursePatrons
  RSpec.describe SubscriptionsController do

    let(:admin) { Fabricate(:admin) }

    before { sign_in(admin) }

    it 'is a subclass of AdminController' do
      expect(DiscoursePatrons::SubscriptionsController < Admin::AdminController).to eq(true)
    end

    it "gets the empty subscriptions" do
      ::Stripe::Subscription.expects(:list)
      get "/patrons/admin/subscriptions.json"
      expect(response.status).to eq(204)
    end
  end
end
