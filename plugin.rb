# name: discourse-donations
# about: Integrates Stripe into Discourse to allow forum visitors to make donations
# version: 1.11.1
# url: https://github.com/chrisbeach/discourse-donations
# authors: Rimian Perkins, Chris Beach, Angus McLeod

gem 'stripe', '2.8.0'

register_asset "stylesheets/discourse-donations.scss"

enabled_site_setting :discourse_donations_enabled

register_html_builder('server:before-head-close') do
  "<script src='https://js.stripe.com/v3/'></script>"
end

after_initialize do
  load File.expand_path('../lib/discourse_donations/engine.rb', __FILE__)
  load File.expand_path('../config/routes.rb', __FILE__)
  load File.expand_path('../app/controllers/controllers.rb', __FILE__)
  load File.expand_path('../app/jobs/jobs.rb', __FILE__)
  load File.expand_path('../app/services/services.rb', __FILE__)

  Discourse::Application.routes.append do
    mount ::DiscourseDonations::Engine, at: 'donate'
  end

  class ::User
    def stripe_customer_id
      if custom_fields['stripe_customer_id']
        custom_fields['stripe_customer_id'].to_s
      else
        nil
      end
    end
  end

  class ::Category
    def donations_cause
      SiteSetting.discourse_donations_causes_categories.split('|').include? self.id.to_s
    end

    def donations_total
      if custom_fields['donations_total']
        custom_fields['donations_total']
      else
        0
      end
    end

    def donations_month
      if custom_fields['donations_month']
        custom_fields['donations_month']
      else
        0
      end
    end

    def donations_backers
      if custom_fields['donations_backers']
        [*custom_fields['donations_backers']].map do |user_id|
          User.find_by(id: user_id.to_i)
        end
      else
        []
      end
    end

    def donations_maintainers
      if custom_fields['donations_maintainers']
        custom_fields['donations_maintainers'].split(',').map do |username|
          User.find_by(username: username)
        end
      else
        []
      end
    end

    def donations_github
      if custom_fields['donations_github']
        custom_fields['donations_github']
      else
        ''
      end
    end
  end

  if SiteSetting.discourse_donations_cause_category
    add_to_serializer(:basic_category, :donations_cause) { object.donations_cause }
    add_to_serializer(:basic_category, :donations_total) { object.donations_total }
    add_to_serializer(:basic_category, :donations_month) { object.donations_month }
    add_to_serializer(:basic_category, :donations_backers) {
      ActiveModel::ArraySerializer.new(object.donations_backers, each_serializer: BasicUserSerializer).as_json
    }
    add_to_serializer(:basic_category, :donations_maintainers) {
      ActiveModel::ArraySerializer.new(object.donations_maintainers, each_serializer: BasicUserSerializer).as_json
    }
    add_to_serializer(:basic_category, :donations_github) { object.donations_github }
  end

  DiscourseEvent.trigger(:donations_ready)
end
