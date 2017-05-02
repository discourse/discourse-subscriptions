require_dependency 'discourse'

module DiscourseDonations
  class ChargesController < ActionController::Base
    include CurrentUser

    skip_before_filter :verify_authenticity_token, only: [:create]

    def create
      if create_account && (email.nil? || email.empty?)
        response = {'message' => 'Please enter your email address'}
      elsif create_account && params[:username].nil?
        response = {'message' => 'Please enter a username'}
      else
        payment = DiscourseDonations::Stripe.new(secret_key, stripe_options)
        response = payment.charge(email, params)
        response['message'] = response['outcome']['seller_message']
      end

      response['rewards'] = []

      if reward?(payment)
        if current_user.present?
          reward = DiscourseDonations::Rewards.new(current_user)
          if reward.add_to_group(group_name)
            response['rewards'] << { type: :group, name: group_name }
          end
          if reward.grant_badge(badge_name)
            response['rewards'] << { type: :badge, name: badge_name }
          end
        elsif email.present?
          if group_name.present?
            store = PluginStore.get('discourse-donations', 'group:add') || []
            PluginStore.set('discourse-donations', 'group:add', store << email)
          end
          if badge_name.present?
            store = PluginStore.get('discourse-donations', 'badge:grant') || []
            PluginStore.set('discourse-donations', 'badge:grant', store << email)
          end
        end
      end

      render :json => response
    end

    private

    def create_account
      params[:create_account] == 'true'
    end

    def reward?(payment)
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
