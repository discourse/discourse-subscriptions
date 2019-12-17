# frozen_string_literal: true

require 'rails_helper'

module DiscourseSubscriptions
  RSpec.describe User::PaymentsController do
    it 'is a subclass of ApplicationController' do
      expect(DiscourseSubscriptions::User::PaymentsController < ::ApplicationController).to eq(true)
    end

    context "not authenticated" do
      it "does not get the payment intents" do
        ::Stripe::PaymentIntent.expects(:list).never
        get "/s/user/payments.json"
      end
    end

    context "authenticated" do
      let(:user) { Fabricate(:user, email: 'zasch@example.com') }

      before do
        sign_in(user)
        Fabricate(:customer, customer_id: 'c_345678', user_id: user.id)
      end

      it "gets payment intents" do
        ::Stripe::PaymentIntent.expects(:list).with(
          customer: 'c_345678'
        )

        get "/s/user/payments.json"
      end

    end
  end
end
