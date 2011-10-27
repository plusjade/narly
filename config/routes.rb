Superwatch::Application.routes.draw do
  root  :to => "home#index"

  match "auth/github/callback" => "sessions#create"
  match "/signout" => "sessions#destroy", :as => :signout
  
end
