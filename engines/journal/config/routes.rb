Journal::Engine.routes.draw do
  resources :posts, except: :new

  root "posts#index"
end
