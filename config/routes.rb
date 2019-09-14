# frozen_string_literal: true

DiscoursePatrons::Engine.routes.draw do
  get '/admin' => 'admin#index'
  get '/' => 'patrons#index'
  get '/:pid' => 'patrons#show'

  resources :patrons, only: [:index, :create]
end
