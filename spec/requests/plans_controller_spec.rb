# frozen_string_literal: true

require 'rails_helper'

module DiscoursePatrons
  RSpec.describe PlansController do
    describe "index" do
      it "lists the active plans" do
        ::Stripe::Plan.expects(:list).with(active: true)
        get "/patrons/plans.json"
      end
    end
  end
end
