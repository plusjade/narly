class User
  include DataMapper::Resource
  include HubWire
  githubify :type => "user"
  
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
      user = load_from_github(login)
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
  def repos(tags)
    tags = Array(tags)
    keys = tags.map { |tag| self.redis_key_for_tag_repos(tag.name) }
    ghids = $redis.send(:sinter, *keys)
    
    # The default repo search should be via the "watched" tag.
    # If there are no repos tagged "watched" for this user it means we haven't loaded this user yet.
    # So we load the user's watched repos from github but only in this default case.
    #
    if (ghids.blank? && tags.count == 1 && tags.first.name == "watched")
      ghids = self.import_watched
    end
      
    Repository.all(:ghid => ghids)
  end
  
  # Get a count of repos tagged with given tag by the given user
  # Tag is a single Tag instance
  #
  def repos_count(tag)
    (tag.is_a?(Tag) ? ($redis.zscore self.redis_key(:tags), tag.name) : 0).to_i
  end
    
  # returns array with tag_name, score.
  # ex: ["ruby", "1", "git", "1"] 
  #
  def tags(limit=nil)
    $redis.zrevrange( 
      self.redis_key(:tags),
      0, 
      (limit.to_i.nil? ? -1 : limit.to_i - 1),
      :with_scores => true
    )
  end
  
  # tag a repo with the given tag name
  # in code-english: plusjade:ghid tags:"mysql" on repo:112 
  # TODO: 
  #  only increment counters is tag-repo doesn't exist.
  #  use Tag instance rather than a string.
  #
  def tag_repo(tag_name, repo_ghid)
    $redis.multi do
    # TAGS  
      #Tag:mysql:users add plusjade.ghid
      $redis.sadd "TAG:#{tag_name.downcase}:users", self.ghid 

      #Tag:mysql:repos add 112
      $redis.sadd "TAG:#{tag_name.downcase}:repos", repo_ghid

    # USER  
      #User:ghid:tags add +1:"mysql"
      $redis.zincrby self.redis_key(:tags), 1, tag_name

      #User:ghid:repos add 112
      $redis.sadd self.redis_key(:repos), repo_ghid
      
      #USER:ghid:tag:"mysql" add 112
      $redis.sadd self.redis_key_for_tag_repos(tag_name), repo_ghid
      
    # REPO  
      #Repo:112:tags  +1:"mysql"
      $redis.zincrby "REPO:#{repo_ghid}:tags", 1, tag_name

      #Repo:112:users add ghid
      $redis.sadd "REPO:#{repo_ghid}:users", self.ghid
    end  

  end
  
  def github_url
    "http://github.com/#{self.login}"
  end
  
  def redis_key(scope)
    "USER:#{self.ghid}:#{scope}"
  end
  
  def redis_key_for_tag_repos(tag)
    "#{redis_key(:tag)}:#{tag}:repos"
  end
  
  # Import watched repos from github.
  # Returns an array of ghids for the imported repos.
  def import_watched
    HubWire::DSL.watched(self.login).map do |repo|
      Repository.new_from_github_hash(repo).save
      self.tag_repo("watched", repo["id"])

      repo["id"]
    end
  end
  
end
