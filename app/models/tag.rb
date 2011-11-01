class Tag
  include TagSystem
  attr_accessor :name
  BlackList = /[^a-z 0-9 + # - .]/

  define_tag_strategy :namespace => "TAG", :scope_by_field => :name

  def initialize(name)
    self.name = name.to_s.downcase.gsub(BlackList, "")
    raise "tag cant be blank" if self.name.blank?
  end
  
  def tag_by_user_repo(user, repo)
    add_tag_associations(user, repo, self)
  end
    
  def untag_by_user_repo(user, repo)
    remove_tag_associations(user, repo, self)
  end
    
  def repos
    $redis.smembers storage_key(:repos)
  end
  
  def users
    $redis.smembers storage_key(:users)
  end
  
  def self.new_from_tag_string(tag_string)
    tag_string.to_s.split(":").map do |name|
      new(name)
    end
  end
  
  # Takes one or more Tag instances (via array) and provides
  # the equivalent tag_string
  #
  def self.to_tag_string(tags)
    Array(tags).map! { |tag| tag.name }.join(":")
  end
   
end