DiscourseDonations::Engine.routes.draw do
  resources :charges, only: [:create]
  get 'users/:username/payments' => 'payments#show'
  get 'donate' => 'payments#show'
end
