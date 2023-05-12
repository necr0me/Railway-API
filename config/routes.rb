Rails.application.routes.draw do
  mount Rswag::Api::Engine => '/api-docs'
  mount Rswag::Ui::Engine => '/api-docs'
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Defines the root path routes ("/")
  # root "articles#index"

  namespace :admin do
    resources :users, only: %i[destroy]

    resources :stations, only: %i[index create update destroy]

    resources :routes, only: %i[index]
    resources :routes, only: %i[show create destroy], param: :route_id
    resources :routes, only: [] do
      post 'stations', to: 'routes#add_station'
      delete 'stations/:station_id', to: 'routes#remove_station'
    end

    resources :carriage_types, only: %i[index create update destroy]

    resources :carriages

    resources :trains, param: :train_id
    resources :trains, only: [] do
      post 'carriages', to: 'trains#add_carriage'
      delete 'carriages/:carriage_id', to: 'trains#remove_carriage'
    end

    resources :train_stops, only: %i[create update destroy]

    resources :tickets, only: %i[destroy]
  end

  namespace :api do
    namespace :v1 do
      resource :users, only: %i[show] do
        post "activate"

        post "reset_email"
        put "update_email"
        patch "update_email"

        post "reset_password"
        put "update_password"
        patch "update_password"
      end

      resources :profiles, only: %i[index create update destroy]

      resources :stations, only: %i[index show]

      resources :carriages, only: %i[show]

      resources :trains, param: :train_id, only: %i[show]

      resources :train_stops, only: %i[index]

      resources :tickets, only: %i[index create destroy]
    end
  end

  namespace :users do
    post 'login', to: 'sessions#create'
    get 'refresh_tokens', to: 'sessions#refresh_tokens'
    delete 'logout', to: 'sessions#destroy'

    post 'sign_up', to: 'registrations#create'
    delete ':id', to: 'registrations#destroy'
  end
end
