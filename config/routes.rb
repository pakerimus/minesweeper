Rails.application.routes.draw do
  resources :users, only: :create

  root 'pages#index'
end
