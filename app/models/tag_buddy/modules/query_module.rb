module TagBuddy

  module Query
    
    # A collection query simply returns members from a given set
    #
    #
    def self.collection(type, conditions)
      via = conditions[:via].is_a?(Array) ? conditions[:via].first : conditions[:via]
      items = $redis.smembers(via.storage_key(type))
      items = items[0, conditions[:limit].to_i] unless conditions[:limit].to_i.zero?
      items
    end
    
    # returns array with tag_name, score.
    # ex: ["ruby", "1", "git", "1"] 
    #
    def self.tags(conditions)
      scope = conditions[:users] || conditions[:items]
      
      $redis.zrevrange( 
        scope.storage_key(:tags),
        0, 
        (conditions[:limit].to_i.nil? ? -1 : conditions[:limit].to_i - 1),
        :with_scores => true
      )
    end
    
    # Get items tagged by this user with a particular tag or set of tags.
    # tags is a single or an array of Tag instances
    #
    def self.items_via(conditions)
      tags = Array(conditions[:tags])
      users = Array(conditions[:users])
      
      # users have different storage_keys, how to merge?
      if users.first.is_a?(User)
        keys = tags.map { |tag| users.first.storage_key(:tag, tag.buddy_named_scope, :items) }
      else
        keys = tags.map { |tag| tag.storage_key(:items) }
      end
        
      items = $redis.send(:sinter, *keys)
      items = items[0, conditions[:limit].to_i] unless conditions[:limit].to_i.zero?
      items
    end
    
    
    # get all users using tags on items
    # TAG:mysql:users (set)
    # ITEM:1:users (set)
    
    #tag.storage_key(:users)
    #item.storage_key(:users)
    #
    def self.users_via(conditions)
      
      keys = Array(conditions[:tags]).map { |tag| tag.storage_key(:users) }
      Array(conditions[:items]).each { |item| keys << item.storage_key(:users) }
        
      users = $redis.send(:sinter, *keys)
      users = users[0, conditions[:limit].to_i] unless conditions[:limit].to_i.zero?
      users
    end
        
  
    def self.tags_via(conditions)
      tag_array = $redis.hget conditions[:users].storage_key(:items, :tags), conditions[:items].buddy_named_scope
      tag_array = tag_array ? ActiveSupport::JSON.decode(tag_array) : []

      tag_array.sort!
    end
    
    
    # Return items that share this item's top 3 tags.  
    # Ideally we want what items share the top 3 tags in *their* top n tags
    # but that's kind of hard right now.
    #
    # This doesn't work
    def self.similar_items(limit=nil)
      keys = tags(3).map {|tag| tag.storage_key(:items) }
      items = $redis.send(:sinter, *keys)
      items.delete(self.items.to_s)
      items = items[0, limit.to_i] unless limit.to_i.zero?
    end
    
  end # Query
  
end # TagBuddy
