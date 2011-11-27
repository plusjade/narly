class User
  include DataMapper::Resource
  include HubWire
  include TaylorSwift::Base
  
  githubify :type => "user"
  tell_taylor_swift :users, :identifier => :login
  
  property :id, Serial
  property :ghid, Integer, :unique => true, :required => true
  property :provider, String, :default => "github"
  property :name, String
  property :login, String, :unique => true, :required => true, :default => ""
  property :email, String
  property :avatar_url, String, :length => 256
  property :created_at, DateTime
  property :updated_at, DateTime
  
  
  def repos(conditions = {})
    names = self.taylor_get(:items , conditions)
    conditions[:via] = Array(conditions[:via])
    # If there are no repos tagged by this user lets try to load them from the api.
    if (names.blank?  && conditions[:via].count.zero?)
      names = self.import_mine + self.import_watched(1)
    end

    Repository.all(names)
  end
    
  def tags(conditions = {})
    Tag.spawn_from_taylor_swift_data(self.taylor_get(:tags, conditions))
  end
  
  # Find from our mysql cache or else try to fetch it from the api
  # Notes:
  #   I tried to overload the native self.first method with this check but
  #   what happens is the self.first method is getting called 
  #   when checking the object for validity i.e. user.valid? or user.save
  #   so we get an infinite loop. Took me a while to figure that out.
  #
  def self.first_or_fetch(*args)
    user = self.first(*args)
    if user.nil? && (login = args.first[:login])
      puts "user to network!"
      user = new_from_github(login)
      user = nil unless user.save
    end

    user
  end
  
  def self.first!(*args)
    self.first_or_fetch(*args) || raise(DataMapper::ObjectNotFoundError, "Could not find user with conditions: #{args.first.inspect}") 
  end
  
  def self.create_with_omniauth(auth)
    create! do |user|
      user.provider = auth["provider"]
      user.ghid = auth["uid"]
      user.name = auth["user_info"]["name"]
      user.login = auth["user_info"]["nickname"]
      user.email = auth["user_info"]["email"]
      user.avatar_url = auth["extra"]["user_hash"]["avatar_url"]
    end
  end
  
  def self.spawn_from_taylor_swift_data(data)
    self.all(:login => data)
  end
  
  def github_url
    "http://github.com/#{self.login}"
  end
  
  
  # Import owned repos from github.
  # Returns an array of resource_identifiers for the imported repos.
  def import_mine
    HubWire::DSL.repositories(self.login).map do |repo|
      r = Repository.new_from_github_hash(repo)
      r.save 
      self.taylor_tag(r, Tag.new(:name => self.login))
      r.full_name
    end
  end
  
  # Import watched repos from github.
  # Returns an array of resource_identifiers for the imported repos.
  def import_watched(page)
    HubWire::DSL.watched(self.login, page).map do |repo|
      r = Repository.new_from_github_hash(repo)
      r.save
      self.taylor_tag(r, Tag.new(:name => "watching"))
      r.full_name
    end
  end
  
end
