# frozen_string_literal: true

DiscoursePatrons::Engine.routes.draw do
  get '/' => 'patrons#index'
  get '/:pid' => 'patrons#index'

  resources :patrons, only: [:index, :create]
end
