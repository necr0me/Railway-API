Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Defines the root path route ("/")
  # root "articles#index"
  namespace :users do
    post 'sign_up', to: 'registrations#create'
    delete ':id', to: 'registrations#destroy'
  end

end
