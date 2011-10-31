class Repository
  include DataMapper::Resource
  include HubWire
  include TagSystem
  
  githubify :type => "repo"
  
  property :id, Serial
  property :ghid, Integer, :unique => true
  property :user_ghid, Integer, :index => true
  property :login, String
  property :name, String
  property :description, Text, :lazy => false
  property :language, String
  property :watchers, Integer
  property :forks, Integer
  property :fork, Boolean

  property :created_at, DateTime
  property :updated_at, DateTime
  
  belongs_to :owner, :model => User, 
    :parent_key => [:ghid],
    :child_key => [:user_ghid]


  def tag_by_user(user, tag)
    make_tag_associations(user, self, tag)
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
  
  def users
    $redis.smembers redis_key(:users)
  end
    
  def html_url
    "http://github.com/#{self.login}/#{self.name}"
  end
  
  def redis_key(scope)
    "REPO:#{self.ghid}:#{scope}"
  end

end
