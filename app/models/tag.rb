class Tag
  include TagSystem
  attr_accessor :name, :total_count, :relative_count

  BlackList = /[^a-z 0-9 + # - .]/

  define_tag_strategy :namespace => "TAG", :scope_by_field => :name

  def initialize(attrs={})
    attrs[:name] = attrs[:name].to_s.downcase.gsub(BlackList, "")

    attrs.each do |k, v|
      if self.respond_to?("#{k}=")
        self.send("#{k}=", v)
      end
    end

    raise "tag cant be blank" if self.name.blank?
  end
  
  # Get all Tags
  def self.all(limit=nil)
    self.new_from_tags_data(
      $redis.zrevrange( 
        "TAGS",
        0, 
        (limit.to_i.nil? ? -1 : limit.to_i - 1),
        :with_scores => true
      )
    )
  end
  
  def tag_by_user_repo(user, repo)
    add_tag_associations(user, repo, self)
  end
    
  def untag_by_user_repo(user, repo)
    remove_tag_associations(user, repo, self)
  end
  
  # Get repos this tag is attached to.
  #  
  def repos(limit = nil)
    ghids = Array($redis.smembers storage_key(:repos))
    ghids = ghids[0, limit.to_i] unless limit.to_i.zero?

    Repository.all(:ghid => ghids).sort! { |x,y|
      ghids.index(x.id) <=> ghids.index(y.id)
    }
  end
  
  # Return an Array of User instances this tag is associated with.
  # A user is attached to a tag when the user tags a repo with said tag.
  #
  def users(limit = nil)
    ghids = Array($redis.smembers storage_key(:users))
    ghids = ghids[0, limit.to_i] unless limit.to_i.zero?
    
    User.all(:ghid => ghids).sort! { |x,y| 
      ghids.index(x.id) <=> ghids.index(y.id)
    }
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
  
  # Return an Array of Repository instances associated with the provided tags.
  # tags can be one or an Array of Tag instances or a tag_string
  #
  def self.repos(tags, limit = nil)
    tags = case tags
    when String
      new_from_tag_string(tags)
    else
      Array(tags)
    end
    
    keys = tags.map { |tag| tag.storage_key(:repos) }
    ghids = $redis.send(:sinter, *keys)
    ghids = ghids[0, limit.to_i] unless limit.to_i.zero?
    
    Repository.all(:ghid => ghids).sort! { |x,y| 
      ghids.index(x.id) <=> ghids.index(y.id)
    }
  end
    
  # tags_data format: 
  #   ["ruby", "1", "git", "1"] 
  #   where scores represent tag count and come directly after their tag.
  #
  def self.new_from_tags_data(tags_data)
    tags = []
    tags_data.each_with_index do |name, i|
			next if (i > 0 && i.odd?)
      tags << new(:name => name, :relative_count => tags_data[i+1])
    end

    tags
  end  
  
  # Takes one or more Tag instances (via array) and provides
  # the equivalent tag_string
  #
  def self.to_tag_string(tags)
    Array(tags).map! { |tag| tag.name }.join(":")
  end
   
end