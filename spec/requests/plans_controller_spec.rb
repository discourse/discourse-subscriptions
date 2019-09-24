# frozen_string_literal: true

require 'rails_helper'

module DiscoursePatrons
  RSpec.describe PlansController do
    let(:admin) { Fabricate(:admin) }

    before { sign_in(admin) }

    it 'is a subclass of AdminController' do
      expect(DiscoursePatrons::PlansController < Admin::AdminController).to eq(true)
    end

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
end
