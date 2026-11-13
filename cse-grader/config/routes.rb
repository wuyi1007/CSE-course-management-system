Rails.application.routes.draw do
  devise_for :users, controllers: {
    passwords: 'devise/passwords'
  }

  root "home#index"
  get "home/index"
  get "catalog/index"
  # Singular resource so each signed-in user manages their own profile
  resource :profile, only: [:show, :update], controller: "profiles"

  # Development password reset helper
  get "password-reset-dev", to: "devise/passwords#development_reset", as: :password_reset_development

  get "up" => "rails/health#show", as: :rails_health_check
  get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker
  get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  
  resources :catalog, only: [:index]

  # Group admin tooling behind /admin to keep privileged actions together
  namespace :admin do
    get "/" => "dashboard#index", as: :dashboard
    get "catalogs/reload"
    get "catalogs/approvals"
    resources :courses do
      resources :sections, except: [:show]
    end
    resource :catalog, only: [] do
      get  :reload           # form to choose term/campus
      post :perform_reload   # calls the API fetcher
      get  :approvals        # list pending instructor/admin users
      post :approve          # approve a user
      post :deny             # reject a user request
    end  
  end
end
