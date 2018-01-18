require_dependency 'discourse'

module DiscourseDonations
  class ChargesController < ApplicationController

    skip_before_action :verify_authenticity_token, only: [:create]
    skip_before_action :check_xhr

    def create
      Rails.logger.info user_params.inspect

      output = { 'messages' => [], 'rewards' => [] }

      if create_account
        if !email.present? || !user_params[:username].present?
          output['messages'] << I18n.t('login.missing_user_field')
        end
        if user_params[:password] && user_params[:password].length > User.max_password_length
          output['messages'] << I18n.t('login.password_too_long')
        end
        if user_params[:username] && ::User.reserved_username?(user_params[:username])
          output['messages'] << I18n.t('login.reserved_username')
        end
      end

      if output['messages'].present?
        render(:json => output.merge(success: false)) and return
      end

      Rails.logger.debug "Creating a Stripe payment"
      payment = DiscourseDonations::Stripe.new(secret_key, stripe_options)

      begin
        Rails.logger.debug "Creating a Stripe charge for #{user_params[:amount]}"
        charge = payment.charge(email, user_params[:stripeToken], user_params[:amount])
      rescue ::Stripe::CardError => e
        err = e.json_body[:error]

        output['messages'] << "There was an error (#{err[:type]})."
        output['messages'] << "Error code: #{err[:code]}" if err[:code]
        output['messages'] << "Decline code: #{err[:decline_code]}" if err[:decline_code]
        output['messages'] << "Message: #{err[:message]}" if err[:message]

        render(:json => output) and return
      end

      if charge['paid'] == true
        output['messages'] << I18n.l(Time.now(), format: :long) + ': ' + I18n.t('donations.payment.success')

        output['rewards'] << { type: :group, name: group_name } if group_name
        output['rewards'] << { type: :badge, name: badge_name } if badge_name

        if create_account && email.present?
          args = user_params.to_h.slice(:email, :username, :password, :name).merge(rewards: output['rewards'])
          Jobs.enqueue(:donation_user, args)
        end
      end

      render :json => output
    end

    private

    def create_account
      user_params[:create_account] == 'true' && SiteSetting.discourse_donations_enable_create_accounts
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

    def user_params
      params.permit(:name, :username, :email, :password, :stripeToken, :amount, :create_account)
    end

    def email
      user_params[:email] || current_user.try(:email)
    end
  end
end
