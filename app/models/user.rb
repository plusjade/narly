class User
  include DataMapper::Resource
  include HubWire
  include TagBuddy::User
  
  githubify :type => "user"
  define_tag_strategy :namespace => "USER", :scope_by_field => :login
  
  property :id, Serial
  property :ghid, Integer, :unique => true, :required => true
  property :provider, String, :default => "github"
  property :name, String
  property :login, String, :required => true
  property :email, String
  property :avatar_url, String, :length => 256
  property :created_at, DateTime
  property :updated_at, DateTime
  
  has n, :repositories, :child_key => [:user_ghid]
  
  
  # Overwrite DM finder to try load_from_github on miss
  # This is so we can save this user behind the scenes.
  #
  def self.first(*args)
    user = super(*args)
    if user.nil? && (login = args.first[:login])
      puts "to network!"
      user = new_from_github(login)
      user = nil unless user.save
    end  

    user
  end

  def self.first!(*args)
    first(*args) || raise(DataMapper::ObjectNotFoundError, "Could not find user with conditions: #{args.first.inspect}") 
  end
  
  def self.create_with_omniauth(auth)
    create! do |user|
      user.provider = auth["provider"]
      user.ghid = auth["uid"]
      user.name = auth["user_info"]["name"]
      user.username = auth["user_info"]["nickname"]
      user.email = auth["user_info"]["email"]
      user.avatar_url = auth["extra"]["user_hash"]["avatar_url"]
    end
  end
  
  def github_url
    "http://github.com/#{self.login}"
  end
  
  # Import watched repos from github.
  # Returns an array of ghids for the imported repos.
  def import_watched
    HubWire::DSL.watched(self.login).map do |repo|
      r = Repository.new_from_github_hash(repo)
      r.save
      self.tag_repo(r, Tag.new(:name => "watched"))
    end
  end

end
