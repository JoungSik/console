Settlement::Engine.routes.draw do
  resources :gatherings do
    resources :members, only: [ :create, :destroy ]
    resources :rounds, except: [ :index ] do
      patch :update_members, on: :member
      resources :items, only: [ :create, :update, :destroy ]
    end
    get :result, on: :member
  end
  root "gatherings#index"
end
