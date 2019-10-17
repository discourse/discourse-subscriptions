# frozen_string_literal: true

require 'rails_helper'

module DiscoursePatrons
  module Admin
    RSpec.describe ProductsController do
      it 'is a subclass of AdminController' do
        expect(DiscoursePatrons::Admin::ProductsController < ::Admin::AdminController).to eq(true)
      end

      context 'unauthenticated' do
        it "does not list the products" do
          ::Stripe::Product.expects(:list).never
          get "/patrons/admin/products.json"
          expect(response.status).to eq(403)
        end

        it "does not create the product" do
          ::Stripe::Product.expects(:create).never
          post "/patrons/admin/products.json"
          expect(response.status).to eq(403)
        end

        it "does not show the product" do
          ::Stripe::Product.expects(:retrieve).never
          get "/patrons/admin/products/prod_qwerty123.json"
          expect(response.status).to eq(403)
        end

        it "does not update the product" do
          ::Stripe::Product.expects(:update).never
          put "/patrons/admin/products/prod_qwerty123.json"
          expect(response.status).to eq(403)
        end

        it "does not delete the product" do
          ::Stripe::Product.expects(:delete).never
          delete "/patrons/admin/products/u2.json"
          expect(response.status).to eq(403)
        end
      end

      context 'authenticated' do
        let(:admin) { Fabricate(:admin) }

        before { sign_in(admin) }

        describe 'index' do
          it "gets the empty products" do
            ::Stripe::Product.expects(:list)
            get "/patrons/admin/products.json"
          end
        end

        describe 'create' do
          it 'is of product type service' do
            ::Stripe::Product.expects(:create).with(has_entry(:type, 'service'))
            post "/patrons/admin/products.json", params: { metadata: { group_name: '' } }
          end

          it 'has a name' do
            ::Stripe::Product.expects(:create).with(has_entry(:name, 'Jesse Pinkman'))
            post "/patrons/admin/products.json", params: { name: 'Jesse Pinkman', metadata: { group_name: '' } }
          end

          it 'has an active attribute' do
            ::Stripe::Product.expects(:create).with(has_entry(active: 'false'))
            post "/patrons/admin/products.json", params: { active: 'false', metadata: { group_name: '' } }
          end

          it 'has a metadata' do
            ::Stripe::Product.expects(:create).with(has_entry(metadata: { group_name: 'discourse-user-group-name' }))
            post "/patrons/admin/products.json", params: { metadata: { group_name: 'discourse-user-group-name' } }
          end
        end

        describe 'show' do
          it 'retrieves the product' do
            ::Stripe::Product.expects(:retrieve).with('prod_walterwhite')
            get "/patrons/admin/products/prod_walterwhite.json"
          end
        end

        describe 'update' do
          it 'updates the product' do
            ::Stripe::Product.expects(:update)
            patch "/patrons/admin/products/prod_walterwhite.json", params: { metadata: { group_name: '' } }
          end
        end

        describe 'delete' do
          it 'deletes the product' do
            ::Stripe::Product.expects(:delete).with('prod_walterwhite')
            delete "/patrons/admin/products/prod_walterwhite.json"
          end
        end
      end
    end
  end
end
