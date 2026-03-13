Rails.application.routes.draw do
  root "contacts#index"

  get    "login",  to: "sessions#new"
  post   "login",  to: "sessions#create"
  delete "logout", to: "sessions#destroy"

  get  "signup", to: "users#new"
  post "signup", to: "users#create"

  resources :contacts do
    collection do
      get  :export
      post :import
    end
  end

  resources :tags
end
