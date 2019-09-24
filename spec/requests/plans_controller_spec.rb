# frozen_string_literal: true

require 'rails_helper'

module DiscoursePatrons
  RSpec.describe PlansController do
    let(:admin) { Fabricate(:admin) }

    before { sign_in(admin) }

    it 'is a subclass of AdminController' do
      expect(DiscoursePatrons::PlansController < Admin::AdminController).to eq(true)
    end

    it "creates a plan" do
      ::Stripe::Plan.expects(:create)
      post "/patrons/admin/plans.json", params: {}
    end
  end
end
