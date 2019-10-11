# frozen_string_literal: true

require 'rails_helper'

module DiscoursePatrons
  RSpec.describe CustomersController do
    describe "create" do
      let(:user) { Fabricate(:user, email: 'hello.2@example.com') }

      before do
        sign_in(user)
      end

      it "creates a customer" do
        ::Stripe::Customer.expects(:create).with(
          email: 'hello.2@example.com',
          source: 'tok_interesting'
        )

        post "/patrons/customers.json", params: { source: 'tok_interesting' }
      end
    end
  end
end
