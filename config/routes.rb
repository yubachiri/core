Rails.application.routes.draw do
  # get 'projects/index'
  # get 'projects/new'
  # post 'projects/create'
  # get 'projects/show'
  resources :projects, only: [:index, :new, :create, :show]
  devise_for :users
  # resource :user
  root 'home#home'
end
