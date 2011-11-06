module TagBuddy

  module Query
    
    # A collection query simply returns members from a given set
    #
    #
    def self.collection(instance, type, limit)
      items = $redis.smembers(instance.storage_key(type))
      items = items[0, limit.to_i] unless limit.to_i.zero?
      items
    end
    
    # returns array with tag_name, score.
    # ex: ["ruby", "1", "git", "1"] 
    #
    def self.tags(class_or_instance, limit=nil)
      $redis.zrevrange( 
        class_or_instance.storage_key(:tags),
        0, 
        (limit.to_i.nil? ? -1 : limit.to_i - 1),
        :with_scores => true
      )
    end
    
    # Get items tagged by this user with a particular tag or set of tags.
    # tags is a single or an array of Tag instances
    #
    def self.items_by_tags(class_or_instance, tags, limit = nil)
      tags = Array(tags)
      
      # users have different storage_keys, how to merge?
      if class_or_instance.is_a?(User)
        keys = tags.map { |tag| class_or_instance.storage_key(:tag, tag.scoped_field, :items) }
      else
        keys = tags.map { |tag| tag.storage_key(:items) }
      end
        
      items = $redis.send(:sinter, *keys)
      items = items[0, limit.to_i] unless limit.to_i.zero?
      items
    end
    
    
    # get all users using tags on items
    # TAG:mysql:users (set)
    # ITEM:1:users (set)
    
    #tag.storage_key(:users)
    #item.storage_key(:users)
    #
    def self.users_via(items, tags, limit = nil)
      keys = Array(tags).map { |tag| tag.storage_key(:users) }
      Array(items).each { |item| keys << item.storage_key(:users) }
        
      users = $redis.send(:sinter, *keys)
      users = users[0, limit.to_i] unless limit.to_i.zero?
      users
    end
        
  
    def self.tags_via(user, item, limit = nil)
      tag_array = $redis.hget user.storage_key(:items, :tags), item.scoped_field
      tag_array = tag_array ? ActiveSupport::JSON.decode(tag_array) : []

      tag_array.sort!
    end
    
  end # Query
  
end # TagBuddy
