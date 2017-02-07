Choice::Engine.routes.draw do
  get 'stripe' => 'choice#create'
  get 'form' => 'choice#index'
end
