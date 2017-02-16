require 'rails_helper'

module DiscoursePayments
  RSpec.describe PaymentsController, type: :controller do
    routes { DiscoursePayments::Engine.routes }
  end
end
