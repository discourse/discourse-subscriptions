# frozen_string_literal: true

require 'stripe'
require 'highline/import'

desc 'Import subscriptions from Stripe'
task 'subscriptions:import' => :environment do
  setup_api
  products = get_stripe_products
  products_to_import = []

  products.each do |product|
    confirm_import = ask("Do you wish to import product #{product[:name]} (id: #{product[:id]}): (y/N)")
    next if confirm_import.downcase != 'y'
    products_to_import << product
  end

  import_products(products_to_import)
  import_subscriptions
end

def get_stripe_products
  puts 'Getting products from Stripe API'
  Stripe::Product.list
end

def import_products(products)
  puts 'Importing products'
  products.each do |product|
    if DiscourseSubscriptions::Product.find_by(external_id: product[:id]).blank?
      DiscourseSubscriptions::Product.create(external_id: product[:id])
    end
  end
end

def import_subscriptions
  puts 'Importing subscriptions'
  product_ids = DiscourseSubscriptions::Product.all.pluck(:external_id)
  subscriptions = Stripe::Subscription.list
  subscriptions_for_products = subscriptions[:data].select { |sub| product_ids.include?(sub[:items][:data][0][:plan][:product]) }

  subscriptions_for_products.each do |subscription|
    product_id = subscription[:items][:data][0][:plan][:product]
    customer_id = subscription[:customer]
    subscription_id = subscription[:id]
    user_id = subscription[:metadata][:user_id].to_i
    username = subscription[:metadata][:username]

    if product_id && customer_id && subscription_id
      customer = DiscourseSubscriptions::Customer.find_by(user_id: user_id, customer_id: customer_id, product_id: product_id)

      # create the customer record if doesn't exist only if the user_id and username match
      # this prevents issues if multiple sites use the same Stripe account
      if customer.nil? && user_id && user_id > 0
        user = User.find(user_id)
        if user && (user.username == username)
          customer = DiscourseSubscriptions::Customer.create(
            user_id: user_id,
            customer_id: customer_id,
            product_id: product_id
          )
        end
      end

      if customer
        if DiscourseSubscriptions::Subscription.find_by(customer_id: customer.id, external_id: subscription_id).blank?
          DiscourseSubscriptions::Subscription.create(
            customer_id: customer.id,
            external_id: subscription_id
          )
        end
      end
    end
  end
end

private

def setup_api
  api_key = SiteSetting.discourse_subscriptions_secret_key || ask('Input Stripe secret key')
  Stripe.api_key = api_key
end
