class User < ActiveRecord::Base
  
  has_many :repositories, :primary_key => "uid", :foreign_key => "user_uid"
  
  
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

  # gh_user is an instance of GitHub:User
  def self.create_with_api(gh_user)
    create! do |user|
      user.provider = "github"
      user.uid = gh_user.id
      user.name = gh_user.name
      user.username = gh_user.login
      user.email = gh_user.email
      user.avatar_url = gh_user.avatar_url
    end
  end
  
  
  # get watched repositories for this uer
  # we want to use hubruby to get the data via github api
  # but for localhost development let's marshal the data and store it in
  # redis - i dont want to depend on nor wait for the network.
  #
  def watched 
    str = $redis.get self.redis_key(:marshalled_watched)
    if str
      puts "local!"
      Marshal.load(str)
    else
      puts "to network!"
      data = GitHub.user(self.username).watched
      $redis.set self.redis_key(:marshalled_watched), Marshal.dump(data)
      data
    end
  end
  
  # returns array with tag_name, score.
  # ex: ["ruby", "1", "git", "1"] 
  #
  def tags
    $redis.zrevrange self.redis_key(:tags), 0, -1, :with_scores => true
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

  def api
    GitHub.user(self.username)
  end


  def save_watched
    self.api.watched.each do |repo|
      Repository.create_with_api(repo)
    end
  end
  
end
