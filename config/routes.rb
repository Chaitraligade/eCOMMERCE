Rails.application.routes.draw do
  # This line mounts Spree's routes at the root of your application.
  # This means, any requests to URLs such as /products, will go to
  # Spree::ProductsController.
  # If you would like to change where this engine is mounted, simply change the
  # :at option to something different.
  #
  
  # We ask that you don't use the :as option here, as Spree relies on it being
  # the default of "spree".

  # This line mounts Spree's routes at the root of your application.
  # This means, any requests to URLs such as /products, will go to
  # Spree::ProductsController.
  # If you would like to change where this engine is mounted, simply change the
  # :at option to something different.
  #
  # We ask that you don't use the :as option here, as Spree relies on it being
  # the default of "spree".
  # mount Spree::Core::Engine, at: '/'
  root "home#index"
  devise_for :admin_users, ActiveAdmin::Devise.config
  ActiveAdmin.routes(self)
  devise_for :users
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check
  # root "products#index"
  resources :products, only: [:index, :show, :create, :new, :edit, :update]
  resources :categories, only: [:index, :show]
  
  resources :orders, only: [:index, :new, :create, :show] do
    member do
      get :thank_you 
      # patch :admin_mark_paid 
      patch 'confirm'    
    end
    collection do
      get 'cart', to: 'orders#cart', as: 'cart_orders'  # Show cart
      post 'add_to_cart', to: 'orders#add_to_cart', as: 'add_to_cart_orders'  # Add product
      delete 'remove_from_cart', to: 'orders#remove_from_cart', as: 'remove_from_cart_orders'  # Remove product
      # post 'checkout'
      get 'checkout'
    end
  end
  # post '/checkout', to: 'orders#checkout', as: 'checkout_order'
  
  # Admin-Specific Order Actions
  namespace :admin do
    resources :orders, only: [:index, :show, :update, :destroy] do
      member do
        patch :mark_paid  # Admin can mark an order as paid
      end
    end
  end
  
  
  authenticate :user, ->(u) { u.admin? } do
    namespace :admin do
      resources :products
    end
  end
 

  direct :rails_blob_path, ActiveStorage::Engine.routes.url_helpers
  # Defines the root path route ("/")
  # root "posts#index"
end
