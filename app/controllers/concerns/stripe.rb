# frozen_string_literal: true

module DiscoursePatrons
  module Stripe
    extend ActiveSupport::Concern

    def set_api_key
      ::Stripe.api_key = 'SiteSetting.discourse_patrons_secret_key'
    end
  end
end
