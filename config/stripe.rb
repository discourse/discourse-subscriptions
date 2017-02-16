
if ENV['STRIPE_SECRET_KEY'].present?
  Rails.configuration.stripe = {
    :publishable_key => ENV['STRIPE_PUBLISHABLE_KEY'],
    :secret_key      => ENV['STRIPE_SECRET_KEY']
  }
else
  Rails.configuration.stripe = {
    :publishable_key => Rails.application.config_for(:stripe)['publishable_key'],
    :secret_key      => Rails.application.config_for(:stripe)['secret_key']
  }
end

Stripe.api_key = Rails.configuration.stripe[:secret_key]
