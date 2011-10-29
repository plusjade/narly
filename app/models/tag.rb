class Tag
  
  attr_accessor :name

  def initialize(name)
    self.name = name.downcase
  end
  
  def redis_key(scope)
    "TAG:#{self.name}:#{scope}"
  end
  
end