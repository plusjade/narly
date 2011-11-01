Superwatch::Application.routes.draw do
  root  :to => "home#index"

  get "/users/:login" => "users#show", :as => :user
  get "/repos/:login/:name" => "repos#show", :as => :repo
  
  match "auth/github/callback" => "sessions#create"
  match "/signout" => "sessions#destroy", :as => :signout
  
end
