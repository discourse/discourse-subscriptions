
TestApp::Application.routes.draw do
  get '/' => 'application#index'
  mount ::Choice::Engine, at: '/choice'
end
