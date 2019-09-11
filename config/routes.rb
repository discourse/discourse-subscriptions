# frozen_string_literal: true

Discourse::Application.routes.append do
  get '/patrons' => 'patrons#index'
end
