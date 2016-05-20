Rails.application.routes.draw do
  devise_for :users

  root 'home#index'

  resources :rows do
    resources :phones
    collection do
      get :export
      get :import_form
      post :import
    end
  end
end
