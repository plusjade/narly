class User
  include DataMapper::Resource
  include HubWire
  include TagSystem
  
  githubify :type => "user"
  define_tag_strategy :namespace => "USER", :scope_by_field => :ghid
  
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
  
  # Get repos tagged by this user.
  # tags is a single or an array of Tag instances
  def repos_by_tags(tags, limit = nil)
    tags = Array(tags)
    keys = tags.map { |tag| self.storage_key_for_tag_repos(tag.name) }
    ghids = $redis.send(:sinter, *keys)
    
    # The default repo search should be via the "watched" tag.
    # If there are no repos tagged "watched" for this user it means we haven't loaded this user yet.
    # So we load the user's watched repos from github but only in this default case.
    #
    if (ghids.blank? && tags.count == 1 && tags.first.name == "watched")
      ghids = self.import_watched
    end
    
    ghids = ghids[0, limit.to_i] unless limit.to_i.zero?
    
    Repository.all(:ghid => ghids, :order => [:name])
  end
  
  # Get a count of repos tagged with given tag by the given user
  # Tag is a single Tag instance
  #
  def repos_count(tag)
    (tag.is_a?(Tag) ? ($redis.zscore self.storage_key(:tags), tag.name) : 0).to_i
  end
  
  def tags(limit=nil)
    Tag.new_from_tags_data(tags_data(limit))
  end
  
  # Tag a repo with the given tag
  # tag is a Tag instance.
  #
  def tag_repo(repo, tag)
    add_tag_associations(self, repo, tag)
  end
  
  def untag_repo(repo, tag)
    remove_tag_associations(self, repo, tag)
  end

  def tags_on_repo(repo)
    tags_on_repo_as_array(repo).map do |name|
      Tag.new(:name => name)
    end
  end
  
  def tags_on_repo_as_array(repo)
    tag_array = $redis.hget self.storage_key(:repos, :tags), repo.ghid
    tag_array = tag_array ? ActiveSupport::JSON.decode(tag_array) : []
    
    tag_array.sort!
  end
    
  def github_url
    "http://github.com/#{self.login}"
  end
  
  
  def storage_key_for_tag_repos(tag)
    storage_key(:tag, tag, :repos)
  end
  
  # Import watched repos from github.
  # Returns an array of ghids for the imported repos.
  def import_watched
    HubWire::DSL.watched(self.login).map do |repo|
      Repository.new_from_github_hash(repo).save
      self.tag_repo(repo["id"], "watched")

      repo["id"]
    end
  end

end
