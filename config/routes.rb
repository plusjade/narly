Superwatch::Application.routes.draw do
  root  :to => "home#index"

  scope "/", :constraints => {:name => /[\w\.-]+/ } do

    get "/users/:login/repos/tagged/:tags" => "users#show", :as => :user_tagged
    get "/users/:login" => "users#show", :as => :user
  

    get "/repos/tagged/:tags" => "repos#index", :as => :repos_tagged
    get "/repos/:login/:name" => "repos#show", :as => :repo
  
    get "/tags" => "tags#show", :as => :tag
    get "/tags" => "tags#index"
  
  end
  
  match "auth/github/callback" => "sessions#create"
  match "/signout" => "sessions#destroy", :as => :signout
  
end
