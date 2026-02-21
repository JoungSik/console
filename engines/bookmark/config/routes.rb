Bookmark::Engine.routes.draw do
  resources :groups
  root "groups#index"
end
