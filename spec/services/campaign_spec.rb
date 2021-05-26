# frozen_string_literal: true

require 'rails_helper'

describe DiscourseSubscriptions::Campaign do
  describe 'campaign data is refreshed' do
    let (:user) { Fabricate(:user) }
    let(:subscription) do
      {
        id: "sub_1234",
        items: {
          data: [
            {
              price: {
                product: "prodct_23456",
                unit_amount: 1000,
                recurring: {
                  interval: "month"
                }
              }
            }
          ]
        }
      }
    end

    let(:product_ids) { ["prodct_23456"] }

    before do
      Fabricate(:product, external_id: "prodct_23456")
      Fabricate(:customer, product_id: "prodct_23456", user_id: user.id, customer_id: 'x')
      SiteSetting.discourse_subscriptions_public_key = "public-key"
      SiteSetting.discourse_subscriptions_secret_key = "secret-key"
    end

    describe "refresh_data" do
      it "refreshes the campaign data properly" do
        ::Stripe::Subscription.expects(:list).returns(data: [subscription], has_more: false)

        DiscourseSubscriptions::Campaign.new.refresh_data

        expect(SiteSetting.discourse_subscriptions_campaign_subscribers).to eq 1
        expect(SiteSetting.discourse_subscriptions_campaign_amount_raised).to eq 1000
        expect(SiteSetting.discourse_subscriptions_campaign_contributors).to eq "#{user.username}"
      end
    end
  end
end
