Inspiration::Engine.routes.draw do
  resources :ideas, except: :new do
    resources :notes, only: %i[create destroy]
  end

  root "ideas#index"
end
