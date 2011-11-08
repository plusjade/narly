module TagBuddy

  module Query
    
    # The dispatcher makes sense of the incoming query and sends
    # it to the appropriate methods for retrieving results.
    #
    # @param [:users, :items, :tags] response_type
    #   Type of resource we expect to return.
    # @param [Hash] conditions 
    #   Optional hash of conditions for filtering, limits, etc.
    #     :via = [Resource, [Resource, Resource, ...]]
    #       Specifies the object or Array of objects you want to query on.
    #       "Query on" is somewhat vague. 
    #       But I trust you can infer from the relationships how a :via condition will work.
    #       Example: @user.buddy_get(:tags, :via => @item)
    #       We expect tags to be returned since our type is :tags
    #       since we are calling buddy_get on @user 
    #       you can infer that we are trying to get "tags from @user via @item"
    #       Or put more accurately : "tags from @user on @item"
    #
    #    :limit = [Integer]
    #      Specifies the limit of objects to return
    #
    def self.dispatch(response_type, conditions)
      raise "Invalid type" unless ValidTypes.include?(response_type)
      via_type = TagBuddy::Utilities.get_type(conditions[:via])
      
      if response_type == :tags
        if via_type
          TagBuddy::Query.tags_via(conditions)
        else
          TagBuddy::Query.tags(conditions)
        end
      elsif response_type == :items
        if via_type
          TagBuddy::Query.items_via(conditions)
        else
          TagBuddy::Query.collection(response_type, conditions)
        end
      elsif response_type == :users
        if via_type
          TagBuddy::Query.users_via(conditions)
        else
          TagBuddy::Query.collection(response_type, conditions)
        end
      end
      
    end
    
    def self.sort_resources(conditions)
      data = {:users => [], :items => [], :tags => []}
      data[TagBuddy::Utilities.get_type(conditions[:scope])] = Array(conditions[:scope])
      data[TagBuddy::Utilities.get_type(conditions[:via])] = Array(conditions[:via])
      data
    end
    
    # A collection query simply returns members from a given set
    #
    def self.collection(type, conditions)
      scope = conditions[:scope] || conditions[:via]
      items = $redis.smembers(scope.storage_key(type))
      items = items[0, conditions[:limit].to_i] unless conditions[:limit].to_i.zero?
      items
    end
    
    # returns array with tag_name, score.
    # ex: ["ruby", "1", "git", "1"] 
    #
    def self.tags(conditions)
      scope = conditions[:scope] || conditions[:via]

      $redis.zrevrange( 
        scope.storage_key(:tags),
        0, 
        (conditions[:limit].to_i.nil? ? -1 : conditions[:limit].to_i - 1),
        :with_scores => (conditions[:with_scores] == false) ? false : true
      )
    end
    
    # Get items tagged by this user with a particular tag or set of tags.
    # tags is a single or an array of Tag instances
    #
    def self.items_via(conditions)
      data = self.sort_resources(conditions)
      
      # users have different storage_keys, how to merge?
      if data[:users].first.is_a?(TagBuddy.resource_models[:user])
        keys = data[:tags].map { |tag| data[:users].first.storage_key(:tag, tag.buddy_named_scope, :items) }
      else
        keys = data[:tags].map { |tag| tag.storage_key(:items) }
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
      data = self.sort_resources(conditions)
      
      keys  = data[:tags].map { |tag| tag.storage_key(:users) }
      keys += data[:items].map { |item| item.storage_key(:users) }
        
      users = $redis.send(:sinter, *keys)
      users = users[0, conditions[:limit].to_i] unless conditions[:limit].to_i.zero?
      users
    end
        
  
    def self.tags_via(conditions)
      data = self.sort_resources(conditions)
      
      tag_array = $redis.hget data[:users].first.storage_key(:items, :tags), data[:items].first.buddy_named_scope
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
