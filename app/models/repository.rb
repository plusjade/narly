class Repository
  include DataMapper::Resource
  include HubWire::Repo
  
  property :id, Serial
  property :ghid, Integer, :unique => true
  property :user_ghid, Integer, :index => true
  property :name, String
  property :description, Text, :lazy => false
  property :language, String
  property :watchers, Integer
  property :forks, Integer

  property :created_at, DateTime
  property :updated_at, DateTime
  
  belongs_to :user, :child_key => [:user_ghid]

  
end
