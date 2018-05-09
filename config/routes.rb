Rails.application.routes.draw do
  get 'users/index'
  resources :projects, only: [:index, :new, :create, :show] do
    resources :users, only: [:index]
    resources :project_members, only: [:new, :create]
  end
  devise_for :users
  root 'home#home'
end
