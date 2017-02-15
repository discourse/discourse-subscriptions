DiscoursePayments::Engine.routes.draw do
  resources :payments, only: [:create]
  get 'users/:username/payments' => 'payments#show'
end
