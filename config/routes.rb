Rails.application.routes.draw do
  namespace :api do
    resources :users, only: :create do
      resources :games, only: [:index, :create, :show, :destroy] do
        member { post :execute }
        resources :cells, only: [:index, :show] do
          member { post :execute }
        end
      end
    end
  end

  get 'pages/index'

  root 'pages#index'
end
