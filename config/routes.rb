# frozen_string_literal: true
require_dependency "subscriptions_user_constraint"

DiscourseSubscriptions::Engine.routes.draw do
  # TODO: namespace this
  scope 'admin' do
    get '/' => 'admin#index'
  end

  namespace :admin do
    resources :plans
    resources :subscriptions, only: [:index, :destroy]
    resources :products
  end

  namespace :user do
    resources :payments, only: [:index]
    resources :subscriptions, only: [:index, :destroy]
  end

  resources :customers, only: [:create]
  resources :hooks, only: [:create]
  resources :plans, only: [:index], constraints: SubscriptionsUserConstraint.new
  resources :products, only: [:index, :show]
  resources :subscriptions, only: [:create]

  post '/subscriptions/finalize' => 'subscriptions#finalize'

  get '/' => 'subscriptions#index', constraints: SubscriptionsUserConstraint.new
  get '/:id' => 'subscriptions#index', constraints: SubscriptionsUserConstraint.new
end
