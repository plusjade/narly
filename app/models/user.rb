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
