# An owner is a the account that owns the repos.
# Owners are different from Users in that a User has authenticated
# via github to use narly.us.
# While an Owner is just part of the data we are showing and tagging.
#
class Owner
  include HubWire
  include TaylorSwift::Base
  
  RedisContainer = "OWNERS"
  
  githubify :type => "user"
  tell_taylor_swift :users, :identifier => :login
  
  attr_accessor :name, :login, :avatar_url
  
  # New Owner instance from the data stored in redis.
  #
  def initialize(data = nil)
    ActiveSupport::JSON.decode(data).each do |k, v|
      self.send("#{k}=", v) if self.respond_to?("#{k}=")
    end if data
  end  
    
  # Build an Owner object from the github_hash which is the data
  # returned from the github api.
  #
  def self.new_from_github_hash(gh_hash ={})
    return nil if gh_hash.blank?
    instance = new

    gh_hash.each do |k, v|
      if instance.respond_to?("#{k}=")
        instance.send("#{k}=", v)
      end
    end

    instance
  end
    
  # Return a singular Owner instance from the database.
  # If the owner doesn't exist in our database try to fetch it from github api.
  #
  def self.first(login)
    owner = $redis.hget RedisContainer, login
    
    if owner
      owner = new(owner)
    else
      owner = self.new_from_github(login)
      owner.save! if owner
    end
      
    owner
  end

  def self.first!(*args)
    self.first(*args) || raise(DataMapper::ObjectNotFoundError, "Could not find user with conditions: #{args.first.inspect}") 
  end
  
  # Return a collection of repo instances from the database.
  #
  def self.all(logins)
    logins = Array(logins)
    return [] if logins.blank?

    owners = $redis.send(:hmget, *logins.unshift(RedisContainer)).compact
    owners.blank? ? [] : owners.map! { |owner| new(owner) } 
  end
  
  # persist to redis but only if not already in the database.
  def save
    $redis.hsetnx RedisContainer, self.login, self.to_json
  end

  # persist to redis and overwrite any existing entry.
  def save!
    $redis.hset RedisContainer, self.login, self.to_json
  end
    
  def repos(conditions = {})
    names = self.taylor_get(:items , conditions)
    conditions[:via] = Array(conditions[:via])
    # If there are no repos tagged by this user lets try to load them from the api.
    if (names.blank?  && conditions[:via].count.zero?)
      names = self.import_mine + self.import_watched(1)
    end

    Repo.all(names)
  end
    
  def tags(conditions = {})
    Tag.spawn_from_taylor_swift_data(self.taylor_get(:tags, conditions))
  end
  
  def github_url
    "http://github.com/#{self.login}"
  end
  
  
  # Import owned repos from github.
  # Returns an array of resource_identifiers for the imported repos.
  def import_mine
    repos = HubWire::DSL.repositories(self.login).map { |repo|
      Repo.new_from_github_hash(repo)
    }
    
    Repo.save_multi!(repos)
    
    # tag the repo and return an array of full_names
    default_tag  = Tag.new(:name => self.login)
    repos.map { |repo| 
      self.taylor_tag(repo, Tag.new(:name => repo.language))  unless repo.language.blank?
      self.taylor_tag(repo, default_tag)
      repo.full_name
    }
  end
  
  # Import watched repos from github.
  # Returns an array of resource_identifiers for the imported repos.
  def import_watched(page)
    repos = HubWire::DSL.watched(self.login, page).map { |repo|
      Repo.new_from_github_hash(repo)
    }
    
    Repo.save_multi!(repos)
    
    # tag the repo and return an array of full_names
    default_tag  = Tag.new(:name => "watching")
    repos.map { |repo| 
      self.taylor_tag(repo, Tag.new(:name => repo.language)) unless repo.language.blank?
      self.taylor_tag(repo, default_tag)
      repo.full_name
    }
  end
    
    
end
