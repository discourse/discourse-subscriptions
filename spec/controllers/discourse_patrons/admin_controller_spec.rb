# frozen_string_literal: true

require 'rails_helper'

module DiscoursePatrons
  RSpec.describe AdminController, type: :controller do
    routes { DiscoursePatrons::Engine.routes }

    it 'is a subclass of AdminController' do
      expect(DiscoursePatrons::AdminController < Admin::AdminController).to eq(true)
    end

    # TODO: authenticate to test these
    it "is ascending"
    it "is has ordered by"
  end
end
