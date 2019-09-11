# frozen_string_literal: true

DiscoursePatrons::Engine.routes.draw do
  get '/' => 'patrons#index'
  get '/:id' => 'patrons#show'
end
