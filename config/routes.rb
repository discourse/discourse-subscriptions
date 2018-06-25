DiscourseDonations::Engine.routes.draw do
  get '/' => 'charges#index'
  resources :charges, only: [:index, :create]
  resources :checkout, only: [:create]
end
