Rails.application.routes.draw do
  devise_for :users

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  root "home#index"

  resources :projects do
    member do
      patch :archive
      post :duplicate
    end

    resources :project_floors, shallow: true, only: [ :new, :create, :edit, :update, :destroy ] do
      resources :rooms, shallow: true, only: [ :new, :create, :edit, :update, :destroy ]
      resources :doors, shallow: true, only: [ :new, :create, :edit, :update, :destroy ]
      resources :windows, shallow: true, only: [ :new, :create, :edit, :update, :destroy ]
    end
    resources :estimates, only: [ :index, :show, :create, :destroy ]
  end

  namespace :admin do
    root to: "dashboard#index"
    resources :material_categories, except: [ :show ]
    resources :materials, except: [ :show ]
    resources :construction_settings, except: [ :show ]
    resources :construction_packages, except: [ :show ]
    resources :calculation_formulas do
      resources :formula_parameters, except: [ :index, :show ]
    end
    resources :labour_rates, except: [ :show ]
    resources :users, only: [ :index, :edit, :update ]
  end
end

