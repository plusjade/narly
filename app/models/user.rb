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
