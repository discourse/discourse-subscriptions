# frozen_string_literal: true

require 'rails_helper'

module DiscourseSubscriptions
  RSpec.describe InvoicesController do
    describe "index" do
      describe "not authenticated" do
        it "does not list the invoices" do
          ::Stripe::Invoice.expects(:list).never
          get "/s/invoices.json"
          expect(response.status).to eq 403
        end
      end

      describe "authenticated" do
        let(:user) { Fabricate(:user) }
        let(:stripe_customer) { { id: 'cus_id4567' } }

        before do
          sign_in(user)
        end

        describe "other user invoices" do
          it "does not list the invoices" do
            ::Stripe::Invoice.expects(:list).never
            get "/s/invoices.json", params: { user_id: 999999 }
          end
        end

        describe "own invoices" do
          context "stripe customer does not exist" do
            it "lists empty" do
              ::Stripe::Invoice.expects(:list).never
              get "/s/invoices.json", params: { user_id: user.id }
              expect(response.body).to eq "[]"
            end
          end

          context "stripe customer exists" do
            before do
              DiscourseSubscriptions::Customer.create_customer(user, stripe_customer)
            end

            it "lists the invoices" do
              ::Stripe::Invoice.expects(:list).with(customer: 'cus_id4567')
              get "/s/invoices.json", params: { user_id: user.id }
            end
          end
        end
      end
    end
  end
end
