class Repository
  include DataMapper::Resource

  property :id, Serial
  property :uid, Integer
  property :user_uid, Integer
  property :name, String
  property :description, Text
  property :language, String
  property :watchers, Integer
  property :forks, Integer

  property :created_at, DateTime
  property :updated_at, DateTime
  

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
