class Repository
  include DataMapper::Resource
  include HubWire
  include TagSystem
  
  githubify :type => "repo"
  define_tag_strategy :namespace => "REPO", :scope_by_field => :ghid
  
  property :id, Serial
  property :ghid, Integer, :unique => true
  property :user_ghid, Integer, :index => true
  property :login, String
  property :name, String
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


  def tag_by_user(user, tag)
    add_tag_associations(user, self, tag)
  end
    
  def untag_by_user(user, tag)
    remove_tag_associations(user, self, tag)
  end  
  
  def tags(limit=nil)
    Tag.new_from_tags_data(tags_data(limit))
  end
      
  def users
    User.all(:ghid => Array($redis.smembers storage_key(:users)))
  end
    
  def html_url
    "http://github.com/#{self.login}/#{self.name}"
  end
  
end
