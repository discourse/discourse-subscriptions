
# This is for building http responses with Fabricate
# Usage: Fabricate(:customer).to_json
# See: https://stripe.com/docs/api

module DiscourseDonations
  class StripeResponse
    attr_accessor :to_json
  end
end
