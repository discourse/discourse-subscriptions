# frozen_string_literal: true
require_dependency "subscriptions_user_constraint"

DiscourseSubscriptions::Engine.routes.draw do
  scope 'admin' do
    get '/' => 'admin#index'
    post '/refresh' => 'admin#refresh_campaign'
    post '/create-campaign' => 'admin#create_campaign'
  end

  namespace :admin do
    resources :plans
    resources :subscriptions, only: [:index, :destroy]
    resources :products
    resources :coupons, only: [:index, :create]
    resource :coupons, only: [:destroy, :update]
  end

  namespace :user do
    resources :payments, only: [:index]
    resources :subscriptions, only: [:index, :destroy]
  end

  get '/' => 'subscribe#index'
  get '.json' => 'subscribe#index'
  get '/contributors' => 'subscribe#get_contributors'
  get '/:id' => 'subscribe#show'
  post '/create' => 'subscribe#create'
  post '/finalize' => 'subscribe#finalize'

  post '/hooks' => 'hooks#create'
end
