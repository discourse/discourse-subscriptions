# frozen_string_literal: true

require 'rails_helper'

module DiscourseSubscriptions
  RSpec.describe HooksController do
    it "responds ok" do
      post "/s/hooks.json"
      expect(response.status).to eq 200
    end
  end
end
