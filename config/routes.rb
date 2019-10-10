# frozen_string_literal: true

DiscoursePatrons::Engine.routes.draw do
  # TODO: namespace this
  scope 'admin' do
    get '/' => 'admin#index'
  end

  namespace :admin do
    resources :plans
    resources :subscriptions, only: [:index]
  end

  get '/' => 'patrons#index'
  get '/:pid' => 'patrons#show'

  resources :patrons, only: [:index, :create]
end
