Rails.application.routes.draw do
  mount JSAdmin::Engine => "/admin"
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # PWA manifest
  get "manifest" => "rails/pwa#manifest", as: :pwa_manifest

  # Defines the root path route ("/")
  root "home#index"

  resources :notices, only: :show
  resource :session, only: %i[new create destroy]
  resource :registration, only: %i[new create] do
    get :verify_pending, on: :collection
    get :verify, on: :collection
  end
  resources :passwords, param: :token, only: %i[new create edit update]

  get "terms", to: "pages#terms"
  get "privacy", to: "pages#privacy"

  get "hotwire-native/path-configuration",
      to: "hotwire_native/path_configurations#show",
      defaults: { format: :json },
      as: :hotwire_native_path_configuration

  namespace :mypage do
    resource :user, only: %i[ show update ]
    resource :theme, only: :update
    resources :push_registrations, only: %i[create destroy]
    resources :plugins, only: %i[ index ] do
      member do
        patch :toggle
      end
    end
    resource :push_notifications, only: %i[show] do
      patch "toggle/:plugin_name/:item_key", action: :toggle, as: :toggle
    end
  end

  # Service Worker는 루트 경로에서 제공
  get "/service-worker.js", to: "service_worker#index", as: :service_worker

  # 플러그인 Engine 마운트
  mount Journal::Engine, at: "/posts", as: "posts"
  mount Todo::Engine, at: "/todos"

  mount MissionControl::Jobs::Engine, at: "/jobs"
end
