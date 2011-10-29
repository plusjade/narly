module HubWire
  
  module Helper
    
    private

    def json(path)
      data = HTTParty.get('https://api.github.com' << path).parsed_response
      data["message"].blank? ? data : {}
    end
    
  end
    
  module User
    include Helper
      
    # get this user
    def get_user
      json("/users/#{self.login}")
    end

    # get repos owned by this user
    def get_repos
      json("/users/#{self.login}/repos")
    end

    # get watched repos from this user
    def get_watched
      json("/users/#{self.login}/watched")
    end

    
  end # User

  module Repo
    include Helper
    
    # get users watching this repo
    def get_watched_by
      json("/repos/#{self.owner.login}/#{self.name}/watchers")
    end

    # get a single repo 
    def get_repo
      json("/repos/#{self.login}/#{self.name}")
    end
    
  end # Repo
  
  
end # Rover
