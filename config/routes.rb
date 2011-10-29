Superwatch::Application.routes.draw do
  root  :to => "home#index"

  get "/users/:username" => "users#show", :as => :user
  
  match "auth/github/callback" => "sessions#create"
  match "/signout" => "sessions#destroy", :as => :signout
  
end
