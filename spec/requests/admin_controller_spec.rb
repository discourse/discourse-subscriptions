# frozen_string_literal: true

require "rails_helper"

module DiscourseSubscriptions
  RSpec.describe AdminController do
    let(:admin) { Fabricate(:admin) }

    before { sign_in(admin) }

    it "is a subclass of AdminController" do
      expect(DiscourseSubscriptions::AdminController < ::Admin::AdminController).to eq(true)
    end

    it "is ok" do
      get "/s/admin.json"
      expect(response.status).to eq(200)
    end
  end
end
