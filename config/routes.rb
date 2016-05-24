Rails.application.routes.draw do
  root 'application#index'

  namespace :sessions do
    get  '/unauthenticated', action: :unauthenticated
    post '/signin',  action: :signin
    get  '/signout', action: :signout
  end

  namespace :api do
    namespace :v1 do
      resources :states, onlt: [:index, :show]
      resources :cities, only: [:index, :show]
      resources :movies, only: [:index, :show]
      resources :movie_theaters, only: [:index, :show]
    end
  end
end
