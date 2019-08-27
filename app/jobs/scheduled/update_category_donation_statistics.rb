# frozen_string_literal: true

module Jobs
  class UpdateCategoryDonationStatistics < ::Jobs::Scheduled
    every 1.day

    def execute(args)
      return unless SiteSetting.discourse_donations_cause_category

      ::Stripe.api_key = SiteSetting.discourse_donations_secret_key
      totals = {}
      backers = {}
      categories = []

      raw_charges = ::Stripe::Charge.list(
        expand: ['data.invoice.subscription', 'data.customer']
      )
      raw_charges = raw_charges.is_a?(Object) ? raw_charges['data'] : []

      raw_charges.each do |c|
        cause_base = c['invoice'] && c['invoice']['subscription'] ? c['invoice']['subscription'] : c
        category_id = cause_base['metadata']['discourse_cause'].to_i

        backer_base = c['customer']
        backer_user_id = backer_base['metadata']['discourse_user_id'].to_i
        backer_email = backer_base['email']

        if category_id > 0 && Category.exists?(id: category_id)
          categories.push(category_id)

          current = totals[category_id] || {}
          amount = c['amount'].to_i
          date = Time.at(c['created']).to_datetime

          totals[category_id] ||= {}
          totals[category_id][:total] ||= 0
          totals[category_id][:month] ||= 0

          totals[category_id][:total] += amount

          if date.month == Date.today.month
            totals[category_id][:month] += amount
          end

          backers[category_id] ||= []

          if backer_user_id > 0 && User.exists?(id: backer_user_id)
            backers[category_id].push(backer_user_id) unless backers[category_id].include? backer_user_id
          elsif user = User.find_by_email(backer_email)
            backers[category_id].push(user.id) unless backers[category_id].include? user.id
          end
        end
      end

      categories.each do |category_id|
        category = Category.find(category_id)

        if totals[category_id]
          category.custom_fields['donations_total'] = totals[category_id][:total]
          category.custom_fields['donations_month'] = totals[category_id][:month]
        end

        if backers[category_id]
          category.custom_fields['donations_backers'] = backers[category_id]
        end

        category.save_custom_fields(true)
      end
    end
  end
end
