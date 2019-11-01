# frozen_string_literal: true

module DiscoursePatrons
  module User
    class SubscriptionsController < ::ApplicationController
      include DiscoursePatrons::Stripe
      before_action :set_api_key
      requires_login

      def index
        begin
          customers = ::Stripe::Customer.list(
            email: current_user.email,
            expand: ['data.subscriptions']
          )

          # TODO: Serialize and remove stuff
          subscriptions = customers[:data].map do |customer|
            customer[:subscriptions][:data]
          end.flatten(1)

          render_json_dump subscriptions

        rescue ::Stripe::InvalidRequestError => e
          return render_json_error e.message
        end
      end
    end
  end
end
