DiscourseDonations::Engine.routes.draw do
  resources :charges, only: [:create, :checkout]
  get 'users/:username/payments' => 'payments#show'
  get 'donate' => 'payments#show'
end
