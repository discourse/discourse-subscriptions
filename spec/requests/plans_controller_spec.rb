# frozen_string_literal: true

require 'rails_helper'

module DiscoursePatrons
  RSpec.describe PlansController do
    let(:admin) { Fabricate(:admin) }

    before { sign_in(admin) }

    it 'is a subclass of AdminController' do
      expect(DiscoursePatrons::PlansController < Admin::AdminController).to eq(true)
    end

    describe "index" do
      it "is ok" do
        ::Stripe::Plan.expects(:list)
        get "/patrons/admin/plans.json"
      end
    end

    describe "create" do
      it "creates a plan with a currency" do
        SiteSetting.stubs(:discourse_patrons_currency).returns('aud')
        ::Stripe::Plan.expects(:create).with(has_entry(:currency, 'aud'))
        post "/patrons/admin/plans.json", params: {}
      end

      it "creates a plan with an interval" do
        ::Stripe::Plan.expects(:create).with(has_entry(:interval, 'week'))
        post "/patrons/admin/plans.json", params: { interval: 'week' }
      end

      it "creates a plan with an amount" do
        ::Stripe::Plan.expects(:create).with(has_entry(:amount, '102'))
        post "/patrons/admin/plans.json", params: { amount: '102' }
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
