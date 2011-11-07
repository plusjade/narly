class User
  include DataMapper::Resource
  include HubWire
  include TagBuddy::Base
  
  githubify :type => "user"
  define_tag_strategy :resource => :user, :scope_by_field => :login
  
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
  
  
  def repos_by_tags(tag, limit=100)
    names = self.items_via(tags, limit)
    
    # The default repo search should be via the "watched" tag.
    # If there are no repos tagged "watched" for this user it means we haven't loaded this user yet.
    # So we load the user's watched repos from github but only in this default case.
    #
    if (names.blank? && tags.count == 1 && tags.first.name == "watched")
      names = self.import_watched
    end

    Repository.all(:full_name => names, :order => [:full_name])
  end  

  def tags_on_item(item)
    self.tags_via(item).map do |name|
      Tag.new(:name => name)
    end
  end
  
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
