# frozen_string_literal: true

require 'rails_helper'

module DiscoursePatrons
  module Admin
    RSpec.describe ProductsController do
      it 'is a subclass of AdminController' do
        expect(DiscoursePatrons::Admin::ProductsController < ::Admin::AdminController).to eq(true)
      end

      context 'unauthenticated' do
        it "does nothing" do
          ::Stripe::Product.expects(:list).never
          get "/patrons/admin/products.json"
          expect(response.status).to eq(403)
        end
      end

      context 'authenticated' do
        let(:admin) { Fabricate(:admin) }

        before { sign_in(admin) }

        it "gets the empty products" do
          ::Stripe::Product.expects(:list)
          get "/patrons/admin/products.json"
        end
      end
    end
  end
end
