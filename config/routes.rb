# frozen_string_literal: true

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
    resources :subscriptions, only: [:index, :destroy]
  end

  resources :customers, only: [:create]
  resources :invoices, only: [:index]
  resources :payments, only: [:create]
  resources :patrons, only: [:index, :create]
  resources :plans, only: [:index]
  resources :products, only: [:index, :show]
  resources :subscriptions, only: [:create]

  get '/:id' => 'patrons#index'
end
