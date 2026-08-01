Rails.application.routes.draw do
  get 'profiles/show'
  get 'profiles/edit'
  get 'profiles/update'
  get 'home/index'
  devise_for :users

  root "home#index"

  resource :profile, only: [:show, :edit, :update]
  resources :posts do
    resource :like, only: [:create, :destroy]
  end
end
