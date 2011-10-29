class Repo
  
  attr_accessor :uid

  def initialize(uid)
    @uid = uid
  end
  
  def redis_key(scope)
    "REPO:#{self.uid}:#{scope}"
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
  
end