Todo::Engine.routes.draw do
  resources :lists do
    resources :items, only: %i[update destroy]
  end

  root "lists#index"
end
