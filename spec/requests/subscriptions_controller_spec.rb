# frozen_string_literal: true

require 'rails_helper'

module DiscoursePatrons
  RSpec.describe SubscriptionsController do
    describe "create" do
      let(:user) { Fabricate(:user, email: 'hello.2@example.com') }

      before do
        sign_in(user)
      end

      it "creates a subscription with a customer" do
        ::Stripe::Subscription.expects(:create).with(has_entry(customer: 'cus_1234'))
        post "/patrons/subscriptions.json", params: { customer: 'cus_1234' }
      end
    end
  end
end
