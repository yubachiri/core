Rails.application.routes.draw do
  resources :projects, only: [:index, :new, :create, :show]
  devise_for :users
  root 'home#home'
end
