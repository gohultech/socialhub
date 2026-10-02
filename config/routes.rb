Rails.application.routes.draw do
  get 'hashtags/show'
  get 'notifications/index'
  devise_for :users

  root "home#index"
  get "search", to: "search#index"
  get "/hashtags/:name", to: "hashtags#show", as: :hashtag

  resource :profile, only: [:show, :edit, :update]
  resources :notifications, only: [:index]

  resources :posts do
    resource :like, only: [:create, :destroy]
    resources :comments, only: [:create, :edit, :update, :destroy]
    resource :saved_post, only: [:create, :destroy]
  end

  resources :saved_posts, only: [:index]

  resources :users, only: [:index, :show] do
    resource :follow, only: [:create, :destroy]
  end

    resources :messages, only: [:index, :show, :create]
end
