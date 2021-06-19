# frozen_string_literal: true

require 'stripe'
require 'highline/import'

desc 'Import data from Procourse Memberships'
task 'subscriptions:procourse_import' => :environment do
  setup_api
  products = get_procourse_stripe_products
  strip_products_to_import = []

  products.each do |product|
    confirm_import = ask("Do you wish to import product #{product[:name]} (id: #{product[:id]}): (y/N)")
    next if confirm_import.downcase != 'y'
    strip_products_to_import << product
  end

  import_procourse_products(strip_products_to_import)
  run_import
end

def get_procourse_stripe_products(starting_after: nil)
  puts 'Getting products from Stripe API'

  all_products = []

  loop do
    products = Stripe::Product.list({ type: 'service', starting_after: starting_after, active: true })
    all_products += products[:data]
    break if products[:has_more] == false
    starting_after = products[:data].last["id"]
  end

  all_products

end

def get_procourse_stripe_subs(starting_after: nil)
  puts 'Getting Procourse Subscriptions from Stripe API'

  all_subscriptions = []

  loop do
    subscriptions = Stripe::Subscription.list({ starting_after: starting_after, status: 'active' })
    all_subscriptions += subscriptions[:data]
    break if subscriptions[:has_more] == false
    starting_after = subscriptions[:data].last["id"]
  end

  all_subscriptions
end

def get_procourse_stripe_customers(starting_after: nil)
  puts 'Getting Procourse Customers from Stripe API'

  all_customers = []

  loop do
    customers = Stripe::Customer.list({ starting_after: starting_after })
    all_customers += customers[:data]
    break if customers[:has_more] == false
    starting_after = customers[:data].last["id"]
  end

  all_customers
end

def import_procourse_products(products)
  puts 'Importing products:'

  products.each do |product|
    puts "Looking for external_id #{product[:id]} ..."
    if DiscourseSubscriptions::Product.find_by(external_id: product[:id]).blank?
      DiscourseSubscriptions::Product.create(external_id: product[:id])
      puts "Subscriptions Product external_id: #{product[:id]} CREATED"
    else
      puts "Subscriptions Product external_id: #{product[:id]} already exists"
    end
  end
end

def run_import
  puts 'Importing Procourse subscriptions'
  product_ids = DiscourseSubscriptions::Product.all.pluck(:external_id)

  all_customers = get_procourse_stripe_customers
  puts "Total available Stripe Customers: #{all_customers.length.to_s}, the first of which is customer id: #{all_customers[0][:description]}"

  all_subscriptions = get_procourse_stripe_subs
  puts "Total Active Procourse Subscriptions available: #{all_subscriptions.length.to_s}"

  subscriptions_for_products = all_subscriptions.select { |sub| product_ids.include?(sub[:items][:data][0][:price][:product]) }
  puts "Total Subscriptions matching Products to Import: #{subscriptions_for_products.length.to_s}"

  subscriptions_for_products.each do |subscription|
    product_id = subscription[:items][:data][0][:plan][:product]
    customer_id = subscription[:customer]
    subscription_id = subscription[:id]
    stripe_customer = all_customers.select { |cust| cust[:id] == customer_id }
    user_id = stripe_customer[0][:description].to_i

    if product_id && customer_id && subscription_id
      subscriptions_customer = DiscourseSubscriptions::Customer.find_by(user_id: user_id, customer_id: customer_id, product_id: product_id)

      if subscriptions_customer.nil? && user_id && user_id > 0
        subscriptions_customer = DiscourseSubscriptions::Customer.create(
          user_id: user_id,
          customer_id: customer_id,
          product_id: product_id
        )
        puts "Subscriptions Customer user_id: #{user_id}, customer_id: #{customer_id}, product_id: #{product_id}) CREATED"
      else
        puts "Subscriptions Customer user_id: #{user_id}, customer_id: #{customer_id}, product_id: #{product_id}) already exists"
      end

      if subscriptions_customer
        if DiscourseSubscriptions::Subscription.find_by(customer_id: subscriptions_customer.id, external_id: subscription_id).blank?
          DiscourseSubscriptions::Subscription.create(
            customer_id: subscriptions_customer.id,
            external_id: subscription_id
          )
          puts "Discourse Subscription customer_id: #{subscriptions_customer.id}, external_id: #{subscription_id}) CREATED"
        else
          puts "Discourse Subscription customer_id: #{subscriptions_customer.id}, external_id: #{subscription_id}) already exists"
        end

        # Update Stripe data for use with discourse_subscriptions
        discourse_user = User.find(user_id)
        puts "Discourse User: #{discourse_user.username_lower} found for Strip metadata update ..."

        updated_subsciption = Stripe::Subscription.update(subscription_id,
                                                          { metadata: { user_id: user_id,
                                                                        username: discourse_user.username_lower } })
        puts "Stripe Subscription: #{updated_subsciption[:id]}, metadata: #{updated_subsciption[:metadata]} UPDATED"

        updated_customer = Stripe::Customer.update(customer_id, { email: discourse_user.email })
        puts "Stripe Customer: #{updated_customer[:id]}, email: #{updated_customer[:email]} UPDATED"

      end
    end
  end
end

private

def setup_api
  api_key = SiteSetting.discourse_subscriptions_secret_key || ask('Input Stripe secret key')
  Stripe.api_key = api_key
end
