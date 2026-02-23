Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # PWA manifest
  get "manifest" => "rails/pwa#manifest", as: :pwa_manifest

  # Defines the root path route ("/")
  root "home#index"

  # 인증
  resource :session
  resources :passwords, param: :token

  # 사용자 설정
  namespace :mypage do
    resource :user, only: %i[ show update ]
    resources :push_subscriptions, only: %i[ create destroy ]
    resources :plugins, only: %i[ index ] do
      member do
        patch :toggle
      end
    end
  end

  # Service Worker는 루트 경로에서 제공
  get "/service-worker.js", to: "service_worker#index", as: :service_worker

  # Service Worker 전용 엔드포인트 (CSRF 토큰 없이 호출됨)
  namespace :service_worker do
    resources :push_subscriptions, only: %i[ create ]
  end

  # 플러그인 Engine 마운트
  mount Settlement::Engine, at: "/settlements"
  mount Todo::Engine, at: "/todos"
  mount Bookmark::Engine, at: "/bookmarks"

  mount MissionControl::Jobs::Engine, at: "/jobs"
end
