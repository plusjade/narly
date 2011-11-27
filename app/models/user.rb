class User
  # Users are github users that have authenticated through github.
  # they are narly.us users. 
  
  include DataMapper::Resource
  include HubWire
  include TaylorSwift::Base

  property :id, Serial
  property :provider, String, :default => "github"
  property :name, String
  property :login, String, :unique => true, :required => true, :default => ""
  property :email, String
  property :avatar_url, String, :length => 256
  
  property :created_at, DateTime
  property :updated_at, DateTime
  
  def self.create_with_omniauth(auth)
    create! do |user|
      user.provider = auth["provider"]
      user.name = auth["user_info"]["name"]
      user.login = auth["user_info"]["nickname"]
      user.email = auth["user_info"]["email"]
    end
  end
  
end