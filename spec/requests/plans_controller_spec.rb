# frozen_string_literal: true

require 'rails_helper'

module DiscoursePatrons
  RSpec.describe PlansController do
    describe "index" do
      it "lists the plans" do
        ::Stripe::Plan.expects(:list)
        get "/patrons/plans.json"
      end
    end
  end
end
