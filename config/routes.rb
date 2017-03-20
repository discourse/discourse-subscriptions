DiscourseDonations::Engine.routes.draw do
  resources :charges, only: [:create]
  get 'users/:username/payments' => 'payments#show'
  get 'dd' => 'payments#show'
end
