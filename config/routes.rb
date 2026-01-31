Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Defines the root path route ("/")
  root "home#index"

  resource :session
  resources :passwords, param: :token

  resources :collections, only: %i[ index show ]

  namespace :mypage do
    resources :collections
    resources :todo_lists do
      resources :todos, only: %i[ update destroy ]
    end
    resource :settings, only: %i[ show ]
    resources :push_subscriptions, only: %i[ create destroy ]
  end

  # Service Worker는 루트 경로에서 제공
  get "/service-worker.js", to: "service_worker#index", as: :service_worker

  mount Rswag::Ui::Engine => "/api-docs"
  mount Rswag::Api::Engine => "/api-docs"

  mount MissionControl::Jobs::Engine, at: "/jobs"
end
