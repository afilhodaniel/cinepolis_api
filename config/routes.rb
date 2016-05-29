Rails.application.routes.draw do
  root 'application#index'

  namespace :sessions do
    get  '/unauthenticated', action: :unauthenticated
    post '/signin',  action: :signin
    get  '/signout', action: :signout
  end

  namespace :api do
    namespace :v2 do
      resources :users,  only: [:create, :show]
      resources :search, only: [:index]
      resources :movies, only: [:show]
    end
  end
end
