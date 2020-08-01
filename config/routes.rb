Rails.application.routes.draw do
  namespace :api do
    resources :users, only: :create do
      resources :games, only: [:index, :create, :show]
    end
  end

  get 'pages/index'

  root 'pages#index'
end
