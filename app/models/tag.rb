class Tag
  include TaylorSwift::Base
  attr_accessor :name, :total_count, :relative_count

  BlackList = /[^a-z 0-9 + # - .]/

  tell_taylor_swift :tags, :identifier => :name

  def initialize(attrs={})
    attrs[:name] = attrs[:name].to_s.downcase.gsub(BlackList, "")

    attrs.each do |k, v|
      if self.respond_to?("#{k}=")
        self.send("#{k}=", v)
      end
    end

    raise "tag cant be blank" if self.name.blank?
  end
  
  def users(conditions = {})
    User.spawn_from_taylor_swift_data(self.taylor_get(:users, conditions))
  end
  
  def repos(conditions = {})
    Repository.spawn_from_taylor_swift_data(self.taylor_get(:items, conditions))
  end
  
  # tags_data format: 
  #   ["ruby", "1", "git", "1"] 
  #   where scores represent tag count and come directly after their tag.
  #
  def self.spawn_from_taylor_swift_data(data)
    tags = []
    data.each_with_index do |name, i|
			next if (i > 0 && i.odd?)
      tags << new(:name => name, :relative_count => data[i+1].to_i)
    end

    tags
  end
  
  # Spawn Tag instances from the given tag_string
  # where tag_string is a String of the format:
  #   tag1:tag2:tag3:tagN:...
  # This format is used in the url as paramater
  #
  def self.new_from_tag_string(tag_string)
    tag_string.to_s.split(":").map do |name|
      new(:name => name)
    end
  end
  
  # Takes one or more Tag instances (via array) and provides
  # the equivalent tag_string
  #
  def self.to_tag_string(tags)
    Array(tags).map! { |tag| tag.taylor_resource_identifier }.join(":")
  end
  
end