require 'rails_helper'

module DiscourseDonations
  RSpec.describe PaymentsController, type: :controller do
    routes { DiscourseDonations::Engine.routes }
  end
end
