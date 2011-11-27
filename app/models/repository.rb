class Repository
  include HubWire
  include TaylorSwift::Base
  attr_accessor :full_name, :login, :avatar_url, :name, :description, :language, :watchers, :forks, :fork # :created_at, :updated_at
  
  githubify :type => "repo"
  tell_taylor_swift :items, :identifier => :full_name
  
  RedisContainer = "REPOS"
  
  # New Repo instance from the data stored in redis.
  #
  def initialize(data = nil)
    ActiveSupport::JSON.decode(data).each do |k, v|
      self.send("#{k}=", v) if self.respond_to?("#{k}=")
    end if data
  end
  
  # New Repo instance from the github api.
  #
  def self.new_from_github_hash(gh_hash={})
    return nil if gh_hash.blank?
    instance = new

    gh_hash.each do |k, v|
      if instance.respond_to?("#{k}=")
        instance.send("#{k}=", v)
      end
    end
    
    instance.login = gh_hash["owner"]["login"]
    instance.avatar_url = gh_hash["owner"]["avatar_url"]
    instance.full_name = "#{instance.login}/#{instance.name}"
    instance
  end
  
  # Return a singular repo instance from the database.
  # If the repo doesn't exist in our database try to fetch it from github api.
  #
  def self.first(full_name)
    repo = $redis.hget RedisContainer, full_name
    
    if repo
      repo = new(repo)
    else
      repo = self.new_from_github(*full_name.split("/"))
      repo.save! if repo
    end
      
    repo
  end
  
  # Return a collection of repo instances from the database.
  #
  def self.all(full_names)
    full_names = Array(full_names)
    return [] if full_names.blank?

    repos = $redis.send(:hmget, *full_names.unshift(RedisContainer)).compact
    repos.blank? ? [] : repos.map! { |repo| new(repo) } 
  end
    
  def self.first!(*args)
    self.first(*args) || raise(DataMapper::ObjectNotFoundError, "Could not find repository with conditions: #{args.first.inspect}") 
  end
  
  # A class level taylor_get method but returns Repo instances for convenience.
  #
  def self.taylor_get_as_resource(conditions)
    self.all(self.taylor_get(conditions))
  end
  
  # persist to redis but only if not already in the database.
  def save
    $redis.hsetnx RedisContainer, self.full_name, self.to_json
  end

  # persist to redis and overwrite any existing entry.
  def save!
    $redis.hset RedisContainer, self.full_name, self.to_json
  end
  
  def tags(conditions = {})
    Tag.spawn_from_taylor_swift_data(self.taylor_get(:tags, conditions))
  end
      
  def users(conditions = {})
    User.spawn_from_taylor_swift_data(self.taylor_get(:users, conditions))
  end
  
  def similar(conditions = {})
    conditions.merge!({:similar => true})
    Repository.all(self.taylor_get(:items, conditions))
  end
  
  def html_url
    "http://github.com/#{self.full_name}"
  end

  def as_json(options ={})
    result = super(options)

    # add methods
    Array(options[:methods]).each do |method|
      next unless respond_to?(method)
      result[method] = __send__(method)
    end

    result
  end

end
