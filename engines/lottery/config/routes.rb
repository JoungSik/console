Lottery::Engine.routes.draw do
  resource :account, only: %i[new create edit update destroy]
  resource :sync, only: :create
  resources :purchases, only: %i[new create] do
    get :preview, on: :collection
  end
  root "overview#show"
end
