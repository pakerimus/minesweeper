Rails.application.routes.draw do
  namespace :api, constraints: { format: 'json' } do
    resources :users, only: :create do
      resources :games, only: [:index, :create, :show, :update, :destroy] do
        resources :cells, only: [:index, :show, :update]
      end
    end
  end

  get 'pages/index'

  root 'pages#index'
end
