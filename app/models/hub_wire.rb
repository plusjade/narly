module HubWire

  def self.included(model)
    model.extend(ClassMethods)
    class << model; attr_accessor :github_object_type end
  end
    
  module ClassMethods

    # Pass the github resource "type" into githubify 
    # This let's us know what resource your model wants to build on top of.
    # Current resources:
    #   User
    #   Repo
    #
    def githubify(opts={})
      opts[:type] ||= "user"
      self.github_object_type = opts[:type].to_s.downcase
    end
    
    
    # Load the raw json response object from github
    # Returns json object.
    #
    def load_json_from_github(login, repo_name = nil)
      type = self.github_object_type
      puts "#{type} to network!"
      
      if type == "user"
        HubWire::DSL::user(login)
      elsif type == "repo"
        HubWire::DSL::repository(login, repo_name)
      else
        {}
      end
    end
    
    # Load a user from github api
    # Returns a DataMapper object
    #
    def new_from_github(login, repo_name = nil)
      new_from_github_hash(load_json_from_github(login, repo_name))
    end

  end # ClassMethods


  # Return JSON from github
  # This was taken from https://github.com/diogenes/hubruby
  #
  module DSL

    def self.user(login)
      json("/users/#{login}")
    end

    def self.following(login)
      json("/users/#{login}/following")
    end

    def self.followers(login)
      json("/users/#{login}/followers")
    end

    def self.repositories(login, page = 1)
      json("/users/#{login}/repos?page=#{page.to_i}&per_page=100")
    end

    def self.watched(login, page = 1)
      json("/users/#{login}/watched?page=#{page.to_i}&per_page=100")
    end

    def self.repository(login, repository_name)
      json("/repos/#{login}/#{repository_name}")
    end

    def self.watched_by(login, repository_name)
      json("/repos/#{login}/#{repository_name}/watchers")
    end

    private

    def self.json(path)
      data = HTTParty.get('https://api.github.com' << path).parsed_response
      if data.is_a?(Array)
        data
      else
        data["message"].blank? ? data : {}
      end
    end

  end # DSL
  
end # HubWire
