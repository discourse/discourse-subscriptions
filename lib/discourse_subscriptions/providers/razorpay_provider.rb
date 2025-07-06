# frozen_string_literal: true

module DiscourseSubscriptions
  module Providers
    class RazorpayProvider
      def self.setup_credentials
        ::Razorpay.setup(
          SiteSetting.discourse_subscriptions_razorpay_key_id,
          SiteSetting.discourse_subscriptions_razorpay_key_secret,
          )
      end

      def self.create_order(amount_in_cents, currency, notes = {}) # Add notes here
        setup_credentials

        receipt_id = "sub_#{SecureRandom.hex(6)}"

        order_options = {
          amount: amount_in_cents,
          currency: currency,
          receipt: receipt_id,
          notes: notes # And add notes to the options
        }

        ::Razorpay::Order.create(order_options)
      end

      def self.verify_payment(payment_id, order_id, signature)
        setup_credentials
        attributes = {
          razorpay_order_id: order_id,
          razorpay_payment_id: payment_id,
          razorpay_signature: signature
        }

        # This function will raise an error if the signature is not valid
        ::Razorpay::Utility.verify_payment_signature(attributes)
        true # Return true if no error is raised
      end
    end
  end
end
