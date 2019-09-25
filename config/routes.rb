# frozen_string_literal: true

DiscoursePatrons::Engine.routes.draw do
  get '/admin' => 'admin#index'
  get '/admin/subscriptions' => 'subscriptions#index'
  get '/admin/plans' => 'plans#index'
  get '/admin/plans/:plan_id' => 'plans#show'
  post '/admin/plans' => 'plans#create'
  get '/' => 'patrons#index'
  get '/:pid' => 'patrons#show'
  resources :patrons, only: [:index, :create]
end
