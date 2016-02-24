Rails.application.routes.draw do
  root 'application#index'

  namespace :sessions do
    get  '/unauthenticated', action: :unauthenticated
    post '/signin',  action: :signin
    get  '/signout', action: :signout
  end

  namespace :api do
    namespace :v1 do
      resources :users, only: [:index, :show, :create, :update, :destroy]

      resources :movies, only: [:index, :show]
      resources :cities, only: [:index]
      resources :movie_theaters, only: [:index]
    end
  end
end
