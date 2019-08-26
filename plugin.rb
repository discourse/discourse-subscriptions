# name: discourse-donations
# about: Integrates Stripe into Discourse to allow forum visitors to make donations
# version: 1.11.2
# url: https://github.com/rimian/discourse-donations
# authors: Rimian Perkins, Chris Beach, Angus McLeod

gem 'stripe', '2.8.0'

register_asset "stylesheets/common/discourse-donations.scss"
register_asset "stylesheets/mobile/discourse-donations.scss"

enabled_site_setting :discourse_donations_enabled

register_html_builder('server:before-head-close') do
  "<script src='https://js.stripe.com/v3/'></script>"
end

extend_content_security_policy(
  script_src: ['https://js.stripe.com/v3/']
)

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

  Category.register_custom_field_type('donations_show_amounts', :boolean)

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

    def donations_show_amounts
      if custom_fields['donations_show_amounts'] != nil
        custom_fields['donations_show_amounts']
      else
        false
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

    def donations_maintainers_label
      if custom_fields['donations_maintainers_label']
        custom_fields['donations_maintainers_label']
      else
        nil
      end
    end

    def donations_github
      if custom_fields['donations_github']
        custom_fields['donations_github']
      else
        nil
      end
    end

    def donations_meta
      if custom_fields['donations_meta']
        custom_fields['donations_meta']
      else
        nil
      end
    end

    def donations_release_latest
      if custom_fields['donations_release_latest']
        custom_fields['donations_release_latest']
      else
        nil
      end
    end

    def donations_release_oldest
      if custom_fields['donations_release_oldest']
        custom_fields['donations_release_oldest']
      else
        nil
      end
    end
  end

  [
    'donations_cause',
    'donations_total',
    'donations_month',
    'donations_backers',
    'donations_show_amounts',
    'donations_maintainers',
    'donations_maintainers_label',
    'donations_github',
    'donations_meta',
    'donations_release_latest',
    'donations_release_oldest'
  ].each do |key|
    Site.preloaded_category_custom_fields << key if Site.respond_to? :preloaded_category_custom_fields
  end


  add_to_serializer(:basic_category, :donations_cause) { object.donations_cause }
  add_to_serializer(:basic_category, :donations_total) { object.donations_total }
  add_to_serializer(:basic_category, :include_donations_total?) { object.donations_show_amounts }
  add_to_serializer(:basic_category, :donations_month) { object.donations_month }
  add_to_serializer(:basic_category, :include_donations_month?) { object.donations_show_amounts && SiteSetting.discourse_donations_cause_month }
  add_to_serializer(:basic_category, :donations_backers) {
    ActiveModel::ArraySerializer.new(object.donations_backers, each_serializer: BasicUserSerializer).as_json
  }
  add_to_serializer(:basic_category, :donations_maintainers) {
    ActiveModel::ArraySerializer.new(object.donations_maintainers, each_serializer: BasicUserSerializer).as_json
  }
  add_to_serializer(:basic_category, :donations_maintainers_label) { object.donations_maintainers_label }
  add_to_serializer(:basic_category, :include_donations_maintainers_label?) { object.donations_maintainers_label.present? }
  add_to_serializer(:basic_category, :donations_github) { object.donations_github }
  add_to_serializer(:basic_category, :donations_meta) { object.donations_meta }
  add_to_serializer(:basic_category, :donations_release_latest) { object.donations_release_latest }
  add_to_serializer(:basic_category, :donations_release_oldest) { object.donations_release_oldest }

  DiscourseEvent.trigger(:donations_ready)
end
