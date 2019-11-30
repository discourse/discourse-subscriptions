# frozen_string_literal: true

require 'rails_helper'

module DiscoursePatrons
  module Admin
    RSpec.describe PlansController do
      it 'is a subclass of AdminController' do
        expect(DiscoursePatrons::Admin::PlansController < ::Admin::AdminController).to eq(true)
      end

      context 'not authenticated' do
        describe "index" do
          it "does not get the plans" do
            ::Stripe::Plan.expects(:list).never
            get "/patrons/admin/plans.json"
          end

          it "not ok" do
            get "/patrons/admin/plans.json"
            expect(response.status).to eq 403
          end
        end

        describe "create" do
          it "does not create a plan" do
            ::Stripe::Plan.expects(:create).never
            post "/patrons/admin/plans.json", params: { name: 'Rick Astley', amount: 1, interval: 'week' }
          end

          it "is not ok" do
            post "/patrons/admin/plans.json", params: { name: 'Rick Astley', amount: 1, interval: 'week' }
            expect(response.status).to eq 403
          end
        end

        describe "show" do
          it "does not show the plan" do
            ::Stripe::Plan.expects(:retrieve).never
            get "/patrons/admin/plans/plan_12345.json"
          end

          it "is not ok" do
            get "/patrons/admin/plans/plan_12345.json"
            expect(response.status).to eq 403
          end
        end

        describe "update" do
          it "does not update a plan" do
            ::Stripe::Plan.expects(:update).never
            delete "/patrons/admin/plans/plan_12345.json"
          end

          it "is not ok" do
            delete "/patrons/admin/plans/plan_12345.json"
            expect(response.status).to eq 403
          end
        end

        describe "delete" do
          it "does not delete a plan" do
            ::Stripe::Plan.expects(:delete).never
            patch "/patrons/admin/plans/plan_12345.json"
          end

          it "is not ok" do
            patch "/patrons/admin/plans/plan_12345.json"
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
            get "/patrons/admin/plans.json"
          end

          it "lists the plans for the product" do
            ::Stripe::Plan.expects(:list).with(product: 'prod_id123')
            get "/patrons/admin/plans.json", params: { product_id: 'prod_id123' }
          end
        end

        describe "show" do
          it "shows a plan" do
            ::Stripe::Plan.expects(:retrieve).with('plan_12345').returns(currency: 'aud')
            get "/patrons/admin/plans/plan_12345.json"
            expect(response.status).to eq 200
          end

          it "upcases the currency" do
            ::Stripe::Plan.expects(:retrieve).with('plan_12345').returns(currency: 'aud')
            get "/patrons/admin/plans/plan_12345.json"
            expect(response.body).to eq '{"currency":"AUD"}'
          end
        end

        describe "create" do
          it "creates a plan with a nickname" do
            ::Stripe::Plan.expects(:create).with(has_entry(:nickname, 'Veg'))
            post "/patrons/admin/plans.json", params: { nickname: 'Veg', metadata: { group_name: '' } }
          end

          it "creates a plan with a currency" do
            ::Stripe::Plan.expects(:create).with(has_entry(:currency, 'AUD'))
            post "/patrons/admin/plans.json", params: { currency: 'AUD', metadata: { group_name: '' } }
          end

          it "creates a plan with an interval" do
            ::Stripe::Plan.expects(:create).with(has_entry(:interval, 'week'))
            post "/patrons/admin/plans.json", params: { interval: 'week', metadata: { group_name: '' } }
          end

          it "creates a plan with an amount" do
            ::Stripe::Plan.expects(:create).with(has_entry(:amount, '102'))
            post "/patrons/admin/plans.json", params: { amount: '102', metadata: { group_name: '' } }
          end

          it "creates a plan with a trial period" do
            ::Stripe::Plan.expects(:create).with(has_entry(:trial_period_days, '14'))
            post "/patrons/admin/plans.json", params: { trial_period_days: '14', metadata: { group_name: '' } }
          end

          it "creates a plan with a product" do
            ::Stripe::Plan.expects(:create).with(has_entry(product: 'prod_walterwhite'))
            post "/patrons/admin/plans.json", params: { product: 'prod_walterwhite', metadata: { group_name: '' } }
          end

          it "creates a plan with an active status" do
            ::Stripe::Plan.expects(:create).with(has_entry(:active, 'false'))
            post "/patrons/admin/plans.json", params: { active: 'false', metadata: { group_name: '' } }
          end

          it 'has a metadata' do
            ::Stripe::Plan.expects(:create).with(has_entry(metadata: { group_name: 'discourse-user-group-name' }))
            post "/patrons/admin/plans.json", params: { metadata: { group_name: 'discourse-user-group-name' } }
          end
        end

        describe "update" do
          it "updates a plan" do
            ::Stripe::Plan.expects(:update)
            patch "/patrons/admin/plans/plan_12345.json", params: { metadata: { group_name: 'discourse-user-group-name' } }
          end
        end

        describe "delete" do
          it "deletes a plan" do
            ::Stripe::Plan.expects(:delete).with('plan_12345')
            delete "/patrons/admin/plans/plan_12345.json"
          end
        end
      end
    end
  end
end
