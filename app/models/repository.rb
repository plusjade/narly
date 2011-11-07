class Repository
  include DataMapper::Resource
  include HubWire
  include TagBuddy::Base
  
  githubify :type => "repo"
  define_tag_strategy :resource => :item, :named_scope => :full_name
  
  property :id, Serial
  property :ghid, Integer, :unique => true, :required => true
  property :user_ghid, Integer, :index => true, :required => true
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
    :parent_key => [:ghid],
    :child_key => [:user_ghid]


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
      
  
  def html_url
    "http://github.com/#{self.full_name}"
  end
  
end
