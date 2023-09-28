# frozen_string_literal: true

describe "Subscription products", type: :system do
  fab!(:admin) { Fabricate(:admin) }
  fab!(:product) { Fabricate(:product, external_id: "prod_OiKyO6ZMFCIhQa") }

  before { SiteSetting.discourse_subscriptions_enabled = true }

  it "shows the login modal" do
    p = DiscourseSubscriptions::Product.first
    visit("/s")

    find("button.login-required.subscriptions").click

    expect(page).to have_css(".modal-container .login-modal")
  end
end
