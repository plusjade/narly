class Repo
  include HubWire::Repo

  attr_accessor :id,
    :login, 
    :name, 
    :html_url, 
    :watchers, 
    :forks, 
    :owner_uid, 
    :language,
    :description
  
  
  def initialize(attributes)

    if attributes["owner"]
      self.owner_uid = attributes["owner"]["id"]
    end  

    attributes.each do |k, v|
      if respond_to?("#{k}=")
        send("#{k}=", v)
      end
    end
    
    
  end
  
  # import the repo into our datastore
  def import
    repo = get_repo
    if repo.blank?
      nil
    else
      $redis.set "REPO:#{repo["id"]}", ActiveSupport::JSON.encode(repo)
      repo
    end
  end
  
    
  # find a repo by id
  def self.find(id)
    repo = $redis.get "REPO:#{id}"
    if repo
      new ActiveSupport::JSON.decode(repo)
    end
    
  end
  
    
  def owner
    User.first(:uid => self.owner_uid)
  end
  
  
  def redis_key(scope)
    "REPO:#{self.id}:#{scope}"
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