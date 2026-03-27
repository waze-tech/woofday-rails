Rails.application.routes.draw do
  # Authentication
  resource :session
  resources :passwords, param: :token
  post "/registrations", to: "registrations#create"
  get "/sign_up", to: "registrations#new", as: :sign_up

  # OAuth
  get "/auth/:provider/callback", to: "omniauth_callbacks#google_oauth2"
  get "/auth/failure", to: "omniauth_callbacks#failure"

  # Pets
  resources :pets

  # Webhooks (must be before authentication)
  namespace :webhooks do
    post "stripe", to: "stripe#create"
  end

  # Pro Setup (onboarding)
  namespace :pros do
    resource :setup, only: %i[ show update ] do
      post :complete
      resources :services, only: %i[ create destroy ], module: :setups
    end
    
    # Subscription management
    resource :subscription, only: %i[ show create ] do
      post :portal
    end
    
    # Pro Dashboard sections
    resources :portfolio_photos, only: %i[ index create destroy ] do
      collection do
        patch :reorder
      end
    end
    resources :availabilities, only: %i[ index create update destroy ]
    resources :blocked_dates, only: %i[ index create destroy ]
  end

  # Pro Profiles
  resources :pro_profiles, path: "pros" do
    resources :bookings, only: [:new, :create]
  end

  # Slug-based pro profile URLs (must be after resources)
  get "/pro/:slug", to: "pro_profiles#show_by_slug", as: :pro_by_slug

  # Bookings
  resources :bookings, only: [:index, :show, :update] do
    resource :review, only: [:new, :create]
  end

  # Search
  get "/search", to: "search#index", as: :search

  # Pricing (Become a Pro)
  get "/pricing", to: "pricing#index", as: :pricing

  # Dashboard
  get "/dashboard", to: "dashboard#show", as: :dashboard

  # Health check
  get "up" => "rails/health#show", as: :rails_health_check

  # Root
  root "home#index"
end
