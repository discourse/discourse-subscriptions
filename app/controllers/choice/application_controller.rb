require_dependency 'discourse'

module Choice
  class ApplicationController < ActionController::Base
    include CurrentUser
  end
end
