Rails.application.routes.draw do

  get 'courier/index'

namespace :v1 do
	resources :routes
	resources :sessions, only: [:create, :destroy]
	resources :locations
end


devise_for :users

require 'sidekiq/web'
mount Sidekiq::Web => "/sidekiq"

get 'genetic_algorithm/index'

root to: 'home#index'

resources :places
get 'home/index'

get "home/new"
get "homefetch/:job_id", controller: :home, action: :fetch
post "home/create"

match ':controller(/:action(/:id))', :via => [:get, :post]

end
