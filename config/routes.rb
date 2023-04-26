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
      post 'add_station', to: 'routes#add_station'
      delete 'remove_station/:station_id', to: 'routes#remove_station'
    end

    resources :carriage_types, only: %i[index create update destroy]

    resources :carriages

    resources :trains, param: :train_id
    resources :trains, only: [] do
      post 'add_carriage', to: 'trains#add_carriage'
      delete 'remove_carriage/:carriage_id', to: 'trains#remove_carriage'
    end

    resources :passing_trains, only: %i[create update destroy]

    resources :tickets, only: %i[destroy]
  end

  namespace :api do
    namespace :v1 do
      resources :users, only: %i[show update]
      resource :profile, only: %i[show create update]

      resources :stations, only: %i[index show]

      resources :carriages, only: %i[show]

      resources :trains, param: :train_id, only: %i[show]

      resources :passing_trains, only: %i[index]

      resources :tickets, only: %i[show create destroy]
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
