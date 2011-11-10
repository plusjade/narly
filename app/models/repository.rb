class Repository
  include DataMapper::Resource
  include HubWire
  include TaylorSwift::Base
  
  githubify :type => "repo"
  tell_taylor_swift :items, :identifier => :full_name
  
  property :id, Serial
  property :ghid, Integer, :unique => true, :required => true
  property :full_name, String, :unique => true, :required => true, :length => 256
  property :login, String, :required => true
  property :name, String, :required => true
  property :description, Text, :lazy => false
  property :language, String
  property :watchers, Integer
  property :forks, Integer
  property :fork, Boolean

  property :created_at, DateTime
  property :updated_at, DateTime
  
  belongs_to :owner, :model => User, 
    :parent_key => [:login],
    :child_key => [:login]


  # Overwrite DM finder to try load_from_github on miss
  # This is so we can save this repo behind the scenes.
  #
  def self.first(*args)
    repo = super(*args)
    if repo.nil? && (login = args.first[:login]) && (name = args.first[:name])
      puts "to network!"
      repo = new_from_github(login, name)
      repo = nil unless repo.save
    end  

    repo
  end
  
  def self.first!(*args)
    first(*args) || raise(DataMapper::ObjectNotFoundError, "Could not find repository with conditions: #{args.first.inspect}") 
  end
  
  def tags(conditions = {})
    Tag.spawn_from_taylor_swift_data(self.taylor_get(:tags, conditions))
  end
      
  def users(conditions = {})
    User.spawn_from_taylor_swift_data(self.taylor_get(:users, conditions))
  end
  
  def similar(conditions = {})
    conditions.merge!({:similar => true})
    Repository.spawn_from_taylor_swift_data(self.taylor_get(:items, conditions))
  end
  
  def html_url
    "http://github.com/#{self.full_name}"
  end
  
  def self.taylor_get_as_resource(conditions)
    self.spawn_from_taylor_swift_data(self.taylor_get(conditions))
  end
  
  def self.spawn_from_taylor_swift_data(data)
    self.all(:full_name => data, :order => [:full_name])
  end
  
end
