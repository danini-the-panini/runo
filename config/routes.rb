Rails.application.routes.draw do
  get "up" => "rails/health#show", as: :rails_health_check

  defaults export: true do
    devise_for :users

    root "home#index"

    resources :games, only: %i[index show create update destroy] do
      resource :players, only: %i[create destroy]
      resource :turn, only: :create
    end
  end
end
