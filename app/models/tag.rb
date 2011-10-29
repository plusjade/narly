class Tag
  
  attr_accessor :name

  def initialize(name)
    self.name = name.downcase
  end
  
  def redis_key(scope)
    "USER:#{self.name}:#{scope}"
  end
  
end