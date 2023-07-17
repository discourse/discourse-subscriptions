# frozen_string_literal: true

require "rails_helper"

RSpec.describe DiscourseSubscriptions::HooksController do
  before do
    SiteSetting.discourse_subscriptions_webhook_secret = "zascharoo"
    SiteSetting.discourse_subscriptions_enabled = true
  end

  it "constructs a webhook event" do
    payload = "we-want-a-shrubbery"
    headers = { HTTP_STRIPE_SIGNATURE: "stripe-webhook-signature" }

    ::Stripe::Webhook
      .expects(:construct_event)
      .with("we-want-a-shrubbery", "stripe-webhook-signature", "zascharoo")
      .returns(type: "something")

    post "/subscriptions/hooks.json", params: payload, headers: headers

    expect(response.status).to eq 200
  end

  describe "event types" do
    let(:user) { Fabricate(:user) }
    let(:customer) do
      Fabricate(:customer, customer_id: "c_575768", product_id: "p_8654", user_id: user.id)
    end
    let(:group) { Fabricate(:group, name: "subscribers-group") }

    let(:event_data) do
      {
        object: {
          customer: customer.customer_id,
          plan: {
            product: customer.product_id,
            metadata: {
              group_name: group.name,
            },
          },
        },
      }
    end

    describe "customer.subscription.updated" do
      before do
        event = { type: "customer.subscription.updated", data: event_data }

        ::Stripe::Webhook.stubs(:construct_event).returns(event)
      end

      it "is successfull" do
        post "/subscriptions/hooks.json"
        expect(response.status).to eq 200
      end

      describe "completing the subscription" do
        it "does not add the user to the group" do
          event_data[:object][:status] = "incomplete"
          event_data[:previous_attributes] = { status: "incomplete" }

          expect { post "/subscriptions/hooks.json" }.not_to change { user.groups.count }

          expect(response.status).to eq 200
        end

        it "does not add the user to the group" do
          event_data[:object][:status] = "incomplete"
          event_data[:previous_attributes] = { status: "something-else" }

          expect { post "/subscriptions/hooks.json" }.not_to change { user.groups.count }

          expect(response.status).to eq 200
        end

        it "adds the user to the group when completing the transaction" do
          event_data[:object][:status] = "complete"
          event_data[:previous_attributes] = { status: "incomplete" }

          expect { post "/subscriptions/hooks.json" }.to change { user.groups.count }.by(1)

          expect(response.status).to eq 200
        end
      end
    end

    describe "customer.subscription.deleted" do
      before do
        event = { type: "customer.subscription.deleted", data: event_data }

        ::Stripe::Webhook.stubs(:construct_event).returns(event)

        group.add(user)
      end

      it "deletes the customer" do
        expect { post "/subscriptions/hooks.json" }.to change { DiscourseSubscriptions::Customer.count }.by(-1)

        expect(response.status).to eq 200
      end

      it "removes the user from the group" do
        expect { post "/subscriptions/hooks.json" }.to change { user.groups.count }.by(-1)

        expect(response.status).to eq 200
      end
    end
  end
end