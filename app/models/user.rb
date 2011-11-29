# Users are github users that have authenticated through github.
# they are narly.us users.
class User
  include DataMapper::Resource

  property :id, Serial
  property :provider, String, :default => "github"
  property :name, String
  property :login, String, :unique => true, :required => true
  property :email, String
  property :avatar_url, String, :length => 256
  
  property :created_at, DateTime
  property :updated_at, DateTime
  
  def self.create_with_omniauth(auth)
    puts "create_with_omniauth"
    user = new
    user.provider = auth["provider"]
    user.login = auth["user_info"]["nickname"]
    user.name = auth["user_info"]["name"]
    user.email = auth["user_info"]["email"]
    user.avatar_url = auth["extra"]["user_hash"]["avatar_url"]
    user.created_at = DateTime.now
    user.save!
    user
  end
  
  def owner
    Owner.first(self.login)
  end
end