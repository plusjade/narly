Superwatch::Application.routes.draw do
  root  :to => "home#index"

  scope "/", :constraints => {:name => /[\w\.-]+/, :repo_name => /[\w\.-]+/, :tags => /[\w:\+#-\.]+/ } do

    get "/users/:login/repos/tagged/:tags(/:format)" => "users#show", :as => :user_tagged
    get "/users/:login/repos/:repo_login/:repo_name/tags(/:format)" => "users#repo_tags", :as => :user_repo_tags
    get "/users/:login/tags(/:format)" => "users#tags", :as => :user_tags
    get "/users/:login/tag" => "users#tag", :as => :user_tag
    get "/users/:login/profile(/:format)" => "users#profile", :as => :user_profile
    get "/users/:login(/:format)" => "users#show", :as => :user
    get "/users/" => "users#show"
    
    get "/repos/tagged/:tags(/:format)" => "repos#index", :as => :repos_tagged
    get "/repos/:repo_login/:repo_name/tags(/:format)" => "repos#tags", :as => :repo_tags
    get "/repos/:repo_login/:repo_name(/:format)" => "repos#show", :as => :repo
  
    get "/tag" => "users#tag", :as => :tag
    get "/untag" => "users#untag", :as => :untag
    get "/tags" => "tags#index", :as => :tags
  
  end
  
  match "auth/github/callback" => "sessions#create"
  match "/signout" => "sessions#destroy", :as => :signout
  
end
