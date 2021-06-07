# frozen_string_literal: true
require_dependency "subscriptions_user_constraint"

DiscourseSubscriptions::Engine.routes.draw do
  scope 'admin' do
    get '/' => 'admin#index'
    post '/refresh' => 'admin#refresh_campaign'
    post '/create-campaign' => 'admin#create_campaign'
  end

  namespace :admin do
    resources :plans, constraints: AdminConstraint.new
    resources :subscriptions, only: [:index, :destroy], constraints: AdminConstraint.new
    resources :products, constraints: AdminConstraint.new
    resources :coupons, only: [:index, :create], constraints: AdminConstraint.new
    resource :coupons, only: [:destroy, :update], constraints: AdminConstraint.new
  end

  namespace :user do
    resources :payments, only: [:index]
    resources :subscriptions, only: [:index, :destroy]
  end

  get '/' => 'subscribe#index'
  get '.json' => 'subscribe#index'
  get '/contributors' => 'subscribe#contributors'
  get '/:id' => 'subscribe#show'
  post '/create' => 'subscribe#create'
  post '/finalize' => 'subscribe#finalize'

  post '/hooks' => 'hooks#create'
end
