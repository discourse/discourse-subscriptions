# frozen_string_literal: true

require 'rails_helper'

module DiscoursePatrons
  RSpec.describe SubscriptionsController do

    let(:admin) { Fabricate(:admin) }

    before { sign_in(admin) }

    it 'is a subclass of AdminController' do
      expect(DiscoursePatrons::SubscriptionsController < Admin::AdminController).to eq(true)
    end

    it "is ok" do
      get "/patrons/admin/subscriptions.json"
      expect(response.status).to eq(200)
    end
  end
end
