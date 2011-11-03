Superwatch::Application.routes.draw do
  root  :to => "home#index"

  scope "/", :constraints => {:name => /[\w\.-]+/, :ghid => /[0-9]+/ } do

    get "/users/:login/repos/tagged/:tags" => "users#show", :as => :user_tagged
    get "/users/:login/repos/:ghid/tags" => "users#repo_tags", :as => :user_repo_tags
    get "/users/:login/tag" => "users#tag", :as => :user_tag
    get "/users/:login" => "users#show", :as => :user
    
    get "/repos/tagged/:tags" => "repos#index", :as => :repos_tagged
    get "/repos/:ghid/tags" => "repos#tags", :as => :repo_tags
    get "/repos/:login/:name" => "repos#show", :as => :repo
  
    get "/tag" => "users#tag", :as => :tag
    get "/tags" => "tags#index", :as => :tags
  
  end
  
  match "auth/github/callback" => "sessions#create"
  match "/signout" => "sessions#destroy", :as => :signout
  
end
