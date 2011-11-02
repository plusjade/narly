class Repository
  include DataMapper::Resource
  include HubWire
  include TagSystem
  
  githubify :type => "repo"
  define_tag_strategy :namespace => "REPO", :scope_by_field => :ghid
  
  property :id, Serial
  property :ghid, Integer, :unique => true, :required => true
  property :user_ghid, Integer, :index => true, :required => true
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
      
  def tag_by_user(user, tag)
    add_tag_associations(user, self, tag)
  end
    
  def untag_by_user(user, tag)
    remove_tag_associations(user, self, tag)
  end  
  
  # Return an Array of Tag instances associated with this Repo.
  # Tags become associated with a repo when a user tags said repo.
  #
  def tags(limit=nil)
    Tag.new_from_tags_data(tags_data(limit))
  end
  
  # Return an Array of User instances this Repo is attached to.
  # A user is attached to a repo when the user tags said repo.
  #    
  def users(limit=nil)
    ghids = Array($redis.smembers storage_key(:users))
    ghids = ghids[0, limit.to_i] unless limit.to_i.zero?

    User.all(:ghid => ghids).sort! { |x,y|
      ghids.index(x.id) <=> ghids.index(y.id)
    }
  end
    
  # Return an Array of Repo instances that share this repo's top 3 tags.  
  # Ideally we want what repos share the top 3 tags in *their* top n tags
  # but that's kind of hard right now.
  #
  def similar_repos(limit=nil)
    keys = tags(3).map {|tag| tag.storage_key(:repos) }
    ghids = $redis.send(:sinter, *keys)
    ghids.delete(self.ghid.to_s)
    ghids = ghids[0, limit.to_i] unless limit.to_i.zero?

    Repository.all(:ghid => ghids).sort! { |x,y|
      ghids.index(x.id) <=> ghids.index(y.id)
    }
  end
    
  def html_url
    "http://github.com/#{self.login}/#{self.name}"
  end
  
end
