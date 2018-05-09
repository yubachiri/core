Rails.application.routes.draw do
  get 'project_members/new'
  get 'users/index'
  resources :projects, only: [:index, :new, :create, :show] do
    resources :users, only: [:index]
  end
  devise_for :users
  root 'home#home'
end
