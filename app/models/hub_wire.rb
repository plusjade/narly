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
    
    def self.included(model)  
      model.extend(self::ClassMethods)
      model.extend(Helper)
    end
    
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

    module ClassMethods
      
      # Load the raw json response object from github
      # Returns json object.
      #
      def load_json_from_github(login)
        json("/users/#{login}")
      end
      
      # Load a user from github api
      # Returns a DataMapper object
      #
      def load_from_github(login)
        attributes = load_json_from_github(login)
        return new() if attributes.blank?
        
        user = new({:provider => "github", :ghid => attributes["id"]})
        attributes.each do |k, v|
          if user.respond_to?("#{k}=")
            user.send("#{k}=", v)
          end
        end
        user.id = nil # we don't want to set this via the attrs
        user
      end

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
