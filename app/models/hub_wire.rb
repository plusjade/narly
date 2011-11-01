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


    # Spawn a new instance from the hash returned from the github api
    #
    def new_from_github_hash(hash)
      return new() if hash.blank?
      
      type = self.github_object_type
      
      if type == "user"
        
        instance = new({:provider => "github", :ghid => hash["id"]})

      elsif type == "repo"

        # Todo: a better way?
        # Make sure we have the owner
        if User.first(:ghid => hash["owner"]["id"]).nil?
          User.new_from_github_hash(hash["owner"]).save
        end

        instance = new({
          :ghid => hash["id"], 
          :user_ghid => hash["owner"]["id"],
          :login => hash["owner"]["login"]
        })
        
        hash.delete("owner")
      else
        instance = new()
      end
      
      hash.each do |k, v|
        if instance.respond_to?("#{k}=")
          instance.send("#{k}=", v)
        end
      end
      
      instance.id = nil # don't set this via the attrs
      instance
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

    def self.repositories(login)
      json("/users/#{login}/repos")
    end

    def self.watched(login)
      json("/users/#{login}/watched")
    end

    def self.repository(login, repository_name)
      json("/repos/#{login}/#{repository_name}")
    end

    def self.watched_by(login, repository_name)
      json("/repos/#{login}/#{repository_name}/watchers")
    end

    private

    def self.json(path)
      HTTParty.get('https://api.github.com' << path).parsed_response
    end

  end # DSL
  
end # HubWire
