Choice::Engine.routes.draw do
  get 'stripe' => 'choice#create'
end
