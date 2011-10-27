class User < ActiveRecord::Base

  
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

  def github_url
    "http://github.com/#{self.username}"
  end

  def api
    GitHub.user(self.username)
  end

end
