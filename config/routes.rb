# frozen_string_literal: true

DiscoursePatrons::Engine.routes.draw do
  # TODO: namespace this
  scope 'admin' do
    get '/' => 'admin#index'
  end

  namespace :admin do
    resources :plans
    resources :subscriptions, only: [:index]
    resources :products
  end

  resources :customers, only: [:create]
  resources :invoices, only: [:index]
  resources :patrons, only: [:index, :create]
  resources :plans, only: [:index]
  resources :products, only: [:index]
  resources :subscriptions, only: [:create]

  get '/' => 'patrons#index'
end
