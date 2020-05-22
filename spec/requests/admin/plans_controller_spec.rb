# frozen_string_literal: true

require 'rails_helper'

module DiscourseSubscriptions
  module Admin
    RSpec.describe PlansController do
      it 'is a subclass of AdminController' do
        expect(DiscourseSubscriptions::Admin::PlansController < ::Admin::AdminController).to eq(true)
      end

      context 'not authenticated' do
        describe "index" do
          it "does not get the plans" do
            ::Stripe::Plan.expects(:list).never
            get "/s/admin/plans.json"
          end

          it "not ok" do
            get "/s/admin/plans.json"
            expect(response.status).to eq 403
          end
        end

        describe "create" do
          it "does not create a plan" do
            ::Stripe::Plan.expects(:create).never
            post "/s/admin/plans.json", params: { name: 'Rick Astley', amount: 1, interval: 'week' }
          end

          it "is not ok" do
            post "/s/admin/plans.json", params: { name: 'Rick Astley', amount: 1, interval: 'week' }
            expect(response.status).to eq 403
          end
        end

        describe "show" do
          it "does not show the plan" do
            ::Stripe::Plan.expects(:retrieve).never
            get "/s/admin/plans/plan_12345.json"
          end

          it "is not ok" do
            get "/s/admin/plans/plan_12345.json"
            expect(response.status).to eq 403
          end
        end

        describe "update" do
          it "does not update a plan" do
            ::Stripe::Plan.expects(:update).never
            delete "/s/admin/plans/plan_12345.json"
          end

          it "is not ok" do
            delete "/s/admin/plans/plan_12345.json"
            expect(response.status).to eq 403
          end
        end

        describe "delete" do
          it "does not delete a plan" do
            ::Stripe::Plan.expects(:delete).never
            patch "/s/admin/plans/plan_12345.json"
          end

          it "is not ok" do
            patch "/s/admin/plans/plan_12345.json"
            expect(response.status).to eq 403
          end
        end
      end

      context 'authenticated' do
        let(:admin) { Fabricate(:admin) }

        before { sign_in(admin) }

        describe "index" do
          it "lists the plans" do
            ::Stripe::Plan.expects(:list).with(nil)
            get "/s/admin/plans.json"
          end

          it "lists the plans for the product" do
            ::Stripe::Plan.expects(:list).with(product: 'prod_id123')
            get "/s/admin/plans.json", params: { product_id: 'prod_id123' }
          end
        end

        describe "show" do
          it "shows a plan" do
            ::Stripe::Plan.expects(:retrieve).with('plan_12345').returns(currency: 'aud')
            get "/s/admin/plans/plan_12345.json"
            expect(response.status).to eq 200
          end

          it "upcases the currency" do
            ::Stripe::Plan.expects(:retrieve).with('plan_12345').returns(currency: 'aud')
            get "/s/admin/plans/plan_12345.json"
            expect(response.parsed_body["currency"]).to eq 'AUD'
          end
        end

        describe "create" do
          it "creates a plan with a nickname" do
            ::Stripe::Plan.expects(:create).with(has_entry(:nickname, 'Veg'))
            post "/s/admin/plans.json", params: { nickname: 'Veg', metadata: { group_name: '' } }
          end

          it "creates a plan with a currency" do
            ::Stripe::Plan.expects(:create).with(has_entry(:currency, 'AUD'))
            post "/s/admin/plans.json", params: { currency: 'AUD', metadata: { group_name: '' } }
          end

          it "creates a plan with an interval" do
            ::Stripe::Plan.expects(:create).with(has_entry(:interval, 'week'))
            post "/s/admin/plans.json", params: { interval: 'week', metadata: { group_name: '' } }
          end

          it "creates a plan with an amount" do
            ::Stripe::Plan.expects(:create).with(has_entry(:amount, '102'))
            post "/s/admin/plans.json", params: { amount: '102', metadata: { group_name: '' } }
          end

          it "creates a plan with a trial period" do
            ::Stripe::Plan.expects(:create).with(has_entry(:trial_period_days, '14'))
            post "/s/admin/plans.json", params: { trial_period_days: '14', metadata: { group_name: '' } }
          end

          it "creates a plan with a product" do
            ::Stripe::Plan.expects(:create).with(has_entry(product: 'prod_walterwhite'))
            post "/s/admin/plans.json", params: { product: 'prod_walterwhite', metadata: { group_name: '' } }
          end

          it "creates a plan with an active status" do
            ::Stripe::Plan.expects(:create).with(has_entry(:active, 'false'))
            post "/s/admin/plans.json", params: { active: 'false', metadata: { group_name: '' } }
          end

          it 'has a metadata' do
            ::Stripe::Plan.expects(:create).with(has_entry(metadata: { group_name: 'discourse-user-group-name' }))
            post "/s/admin/plans.json", params: { metadata: { group_name: 'discourse-user-group-name' } }
          end
        end

        describe "update" do
          it "updates a plan" do
            ::Stripe::Plan.expects(:update)
            patch "/s/admin/plans/plan_12345.json", params: { metadata: { group_name: 'discourse-user-group-name' } }
          end
        end

        describe "delete" do
          it "deletes a plan" do
            ::Stripe::Plan.expects(:delete).with('plan_12345')
            delete "/s/admin/plans/plan_12345.json"
          end
        end
      end
    end
  end
end
