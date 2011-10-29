class User
  include DataMapper::Resource
  
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
  
  
  def self.create_with_omniauth(auth)
    create! do |user|
      user.provider = auth["provider"]
      user.uid = auth["uid"]
      user.name = auth["user_info"]["name"]
      user.username = auth["user_info"]["nickname"]
      user.email = auth["user_info"]["email"]
      user.avatar_url = auth["extra"]["user_hash"]["avatar_url"]
    end
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
  # in code-english: plusjade:uid tags:"mysql" on repo:112 
  #
  def tag_repo(tag_name, repo_uid)
    $redis.multi do
    # TAGS  
      #Tag:mysql:users add plusjade.uid
      $redis.sadd "TAG:#{tag_name.downcase}:users", self.uid 

      #Tag:mysql:repos add 112
      $redis.sadd "TAG:#{tag_name.downcase}:repos", repo_uid

    # USER  
      #User:uid:tags add +1:"mysql"
      $redis.zincrby self.redis_key(:tags), 1, tag_name

      #User:uid:repos add 112
      $redis.sadd self.redis_key(:repos), repo_uid

    # REPO  
      #Repo:112:tags  +1:"mysql"
      $redis.zincrby "REPO:#{repo_uid}:tags", 1, tag_name

      #Repo:112:users add uid
      $redis.sadd "REPO:#{repo_uid}:users", self.uid
    end  

  end
  
  def github_url
    "http://github.com/#{self.username}"
  end
  
  def redis_key(scope)
    "USER:#{self.uid}:#{scope}"
  end
  
end
