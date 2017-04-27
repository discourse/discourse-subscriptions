require_dependency 'discourse'

module DiscourseDonations
  class ChargesController < ActionController::Base
    include CurrentUser

    skip_before_filter :verify_authenticity_token, only: [:create]

    def create
      if email.present?
        payment = DiscourseDonations::Stripe.new(secret_key, stripe_options)
        response = payment.charge(email, params)
      else
        response = {}
      end

      response['rewards'] = []

      if reward_user?(payment)
        reward = DiscourseDonations::Rewards.new(current_user)
        if reward.add_to_group(group_name)
          response['rewards'] << { type: :group, name: group_name }
        end
        if reward.grant_badge(badge_name)
          response['rewards'] << { type: :badge, name: badge_name }
        end
      end

      render :json => response
    end

    private

    def reward_user?(payment)
      payment.present? && payment.successful?
    end

    def group_name
      SiteSetting.discourse_donations_reward_group_name
    end

    def badge_name
      SiteSetting.discourse_donations_reward_badge_name
    end

    def secret_key
      SiteSetting.discourse_donations_secret_key
    end

    def stripe_options
      {
        description: SiteSetting.discourse_donations_description,
        currency: SiteSetting.discourse_donations_currency
      }
    end

    def email
      params[:email] || current_user.try(:email)
    end
  end
end
