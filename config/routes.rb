Rails.application.routes.draw do
  devise_for :users

  root 'home#index'

  resources :rows do
    resources :phones
  end
end
