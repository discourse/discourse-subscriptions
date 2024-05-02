# frozen_string_literal: true

RSpec.describe "Pricing Table", type: :system, js: true do
  fab!(:admin)
  fab!(:product) { Fabricate(:product, external_id: "prod_OiK") }
  let(:dialog) { PageObjects::Components::Dialog.new }
  let(:product_subscriptions_page) { PageObjects::Pages::AdminSubscriptionProduct.new }

  before do
    sign_in(admin)
    SiteSetting.discourse_subscriptions_enabled = true
    SiteSetting.discourse_subscriptions_extra_nav_subscribe = true

    SiteSetting.discourse_subscriptions_secret_key = "sk_test_51xuu"
    SiteSetting.discourse_subscriptions_public_key = "pk_test_51xuu"

    SiteSetting.discourse_subscriptions_pricing_table_enabled = true

    # this needs to be stubbed or it will try to make a request to stripe
    one_product = {
      id: "prod_OiK",
      active: true,
      name: "Tomtom",
      metadata: {
        description: "Photos of tomtom",
        repurchaseable: true,
      },
    }
    ::Stripe::Product.stubs(:list).returns({ data: [one_product] })
    ::Stripe::Product.stubs(:delete).returns({ id: "prod_OiK" })
    ::Stripe::Product.stubs(:retrieve).returns(one_product)
    ::Stripe::Price.stubs(:list).returns({ data: [] })
  end

  it "Links to the pricing table page" do
    visit("/")

    link = find("li.nav-item_subscribe a")
    uri = URI.parse(link[:href])
    expect(uri.path).to eq("/s/subscriptions")
  end

  it "Links to the old page when disabled" do
    SiteSetting.discourse_subscriptions_pricing_table_enabled = false
    visit("/")

    link = find("li.nav-item_subscribe a")
    uri = URI.parse(link[:href])
    expect(uri.path).to eq("/s")
  end

  it "Old subscribe page still works when disabled" do
    SiteSetting.discourse_subscriptions_pricing_table_enabled = false
    visit("/")

    find("li.nav-item_subscribe a").click
    expect(page).to have_selector("div.title-wrapper h1", text: "Subscribe")
  end

  it "Shows a message when not setup yet" do
    visit("/")

    find("li.nav-item_subscribe a").click

    expect(page).to have_selector(
      "div.container",
      text: "There are currently no products available.",
    )
  end
end
