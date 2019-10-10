# frozen_string_literal: true

DiscoursePatrons::Engine.routes.draw do
  scope 'admin' do
    get '/' => 'admin#index'

    resources :subscriptions, only: [:index]
  end

  namespace :admin do
    resources :plans
  end

  get '/' => 'patrons#index'
  get '/:pid' => 'patrons#show'

  resources :patrons, only: [:index, :create]
end
