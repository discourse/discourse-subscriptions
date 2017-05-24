require_dependency 'discourse'

module DiscourseDonations
  class ChargesController < ActionController::Base
    include CurrentUser

    skip_before_filter :verify_authenticity_token, only: [:create]

    def create
      params.permit(:name, :username, :email, :password, :stripeToken, :amount, :plan, :create_account)

      output = { 'messages' => [], 'rewards' => [] }

      if create_account
        if !email.present? || !params[:username].present?
          output['messages'] << I18n.t('login.missing_user_field')
        end
        if params[:password] && params[:password].length > User.max_password_length
          output['messages'] << I18n.t('login.password_too_long')
        end
        if params[:username] && ::User.reserved_username?(params[:username])
          output['messages'] << I18n.t('login.reserved_username')
        end
      end

      if output['messages'].present?
        render(:json => output.merge(success: false)) and return
      end

      payment = DiscourseDonations::Stripe.new(secret_key, stripe_options)

      begin
        if params['amount'].present?
          charge = payment.subscribe(email, params.merge(plan: params[:amount]))
        else
          charge = payment.subscribe(email, params)
        end
      rescue ::Stripe::CardError => e
        err = e.json_body[:error]

        output['messages'] << "There was an error (#{err[:type]})."
        #output['messages'] << "Error code: #{err[:code]}" if err[:code]
        #output['messages'] << "Decline code: #{err[:decline_code]}" if err[:decline_code]
        output['messages'] << "Message: #{err[:message]}" if err[:message]

        render(:json => output) and return
      end

      if charge['paid'] == true || charge['status'] == 'active'
        output['success'] = true

        output['messages'] << I18n.t('donations.payment.success')

        output['rewards'] << { type: :group, name: group_name } if group_name
        output['rewards'] << { type: :badge, name: badge_name } if badge_name

        if create_account && email.present?
          args = params.slice(:email, :username, :password, :name).merge(rewards: output['rewards'])
          Jobs.enqueue(:donation_user, args)
        end
      end

      render :json => output
    end

    private

    def create_account
      params[:create_account] == 'true' && SiteSetting.discourse_donations_enable_create_accounts
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
