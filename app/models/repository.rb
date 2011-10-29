class Repository
  include DataMapper::Resource
  include HubWire::User
  
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

  #GitHub::Repository
  def self.create_with_api(gh_repo)
    if repo = self.find_by_uid(gh_repo.id.to_i)
      return repo
    else
      create! do |repo|
        repo.uid = gh_repo.id
        repo.user_uid = gh_repo.owner.login["id"]
        repo.name = gh_repo.name
        repo.description = gh_repo.description
        repo.language = gh_repo.language
        repo.watchers = gh_repo.watchers
        #repo.forks = gh_repo.forks
      end
    end
    
    
  end
  
end
