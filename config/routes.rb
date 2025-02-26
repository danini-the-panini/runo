Rails.application.routes.draw do
  devise_for :users
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  get "up" => "rails/health#show", as: :rails_health_check

  root "home#index"

  resources :games, only: %i[show create update destroy] do
    resource :players, only: %i[create destroy]
    resource :turn, only: :create
  end
end
