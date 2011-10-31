class Tag
  
  attr_accessor :name

  BlackList = /[^a-z 0-9 + # - .]/
  
  def initialize(name)
    self.name = name.to_s.downcase.gsub(BlackList, "")
    raise "tag cant be blank" if self.name.blank?
  end
  
  def redis_key(scope)
    "TAG:#{self.name}:#{scope}"
  end
  
  def repos
    $redis.smembers redis_key(:repos)
  end
  
  def users
    $redis.smembers redis_key(:users)
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