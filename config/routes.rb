DiscoursePayments::Engine.routes.draw do
  resources :choice, only: [:create]
  get 'users/:username/payments' => 'choice#show'
end
