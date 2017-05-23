Rails.application.routes.draw do

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

  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
