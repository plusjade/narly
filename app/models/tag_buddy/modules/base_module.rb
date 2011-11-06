module TagBuddy
  StorageDeliminator = ":"

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
    
  end
  
  # These are instance methods that get included on all 3 models.
  #
  module Base
  
    # Record everything needed to make user<->rep tag associations.
    # We use redis to store associations and counts relative to those associations.
    #
    # Notes:
    #   $redis.sadd returns bool for singular value additions.
    #   Bool value reflects whether the insertion was newly added.
    #
    def add_tag_association(*args)
      args << self
      data = {}
      args.each { |o| data[o.class.namespace.downcase.to_sym] = o }
    
      # Add ITEM to the USER'S total ITEM data relative to TAG
      is_new_tag_on_item_for_user = ($redis.sadd data[:user].storage_key_for_tag_items(data[:tag].scoped_field), data[:item].scoped_field)

      $redis.multi do
        # Add ITEM to the USERS's total ITEM data.
        $redis.sadd data[:user].storage_key(:items), data[:item].scoped_field

        # Add USER to the ITEM's total USER data
        $redis.sadd data[:item].storage_key(:users), data[:user].scoped_field
      
        # Add USER to the TAG's total USER data.
        $redis.sadd data[:tag].storage_key(:users), data[:user].scoped_field

        # Add ITEM to the TAG's total ITEM data.
        $redis.sadd data[:tag].storage_key(:items), data[:item].scoped_field
      
        if is_new_tag_on_item_for_user
          # Increment the USER's TAG count for TAG
          $redis.zincrby data[:user].storage_key(:tags), 1, data[:tag].scoped_field
        
          # Increment the ITEM's TAG count for TAG
          $redis.zincrby data[:item].storage_key(:tags), 1, data[:tag].scoped_field
        end
      
        # Add TAG to total TAG data
        $redis.zincrby data[:tag].class.storage_key(:tags) , 1, data[:tag].scoped_field

      end

      # Add TAG to USER's tag data relative to ITEM
      # (this is kept in a dictionary to save memory)
      tag_array = data[:user].tags_on_item_as_array(data[:item])
      tag_array.push(data[:tag].scoped_field).uniq!
      $redis.hset data[:user].storage_key(:items, :tags), data[:item].scoped_field, ActiveSupport::JSON.encode(tag_array)

    end
  
    # Record everything needed to remove user<->item tag associations.
    # We use redis to store associations and counts relative to those associations.
    #
    # Notes:
    #   $redis.srem returns bool for singular value additions.
    #   Bool value reflects whether the the key exist before it was removed.
    #
    def remove_tag_association(*args)
      args << self
      data = {}
      args.each { |o| data[o.class.namespace.downcase.to_sym] = o }
    
      # Remove ITEM from the USER'S total ITEM data relative to TAG
      was_removed_tag_on_item_for_user = ($redis.srem data[:user].storage_key_for_tag_items(data[:tag].scoped_field), data[:item].scoped_field)

      $redis.multi do
        # Remove ITEM from the USERS's total ITEM data.
        $redis.srem data[:user].storage_key(:items), data[:item].scoped_field

        # Remove USER from the ITEM's total USER data
        $redis.srem data[:item].storage_key(:users), data[:user].scoped_field
      
        # Remove USER from the TAG's total USER data.
        $redis.srem data[:tag].storage_key(:users), data[:user].scoped_field

        # Remove ITEM from the TAG's total ITEM data.
        $redis.srem data[:tag].storage_key(:items), data[:item].scoped_field
      end
    
      if was_removed_tag_on_item_for_user
        # Decrement the USER's TAG count for TAG
        if($redis.zincrby data[:user].storage_key(:tags), -1, data[:tag].scoped_field).to_i <= 0
          $redis.zrem data[:user].storage_key(:tags), data[:tag].scoped_field
        end
      
        # Decrement the ITEM's TAG count for TAG
        if ($redis.zincrby data[:item].storage_key(:tags), -1, data[:tag].scoped_field).to_i <= 0
          $redis.zrem data[:item].storage_key(:tags), data[:tag].scoped_field
        end
      end
      
      # Decrement TAG count in TAG data
      if ($redis.zincrby data[:tag].class.storage_key(:tags), -1, data[:tag].scoped_field).to_i <= 0
        $redis.zrem data[:tag].class.storage_key(:tags), data[:tag].scoped_field
      end
    
      # REMOVE TAG from USER's tag data relative to ITEM
      # (this is kept in a dictionary to save memory)
      tag_array = data[:user].tags_on_item_as_array(data[:item])
      tag_array.delete(data[:tag].scoped_field)
      $redis.hset data[:user].storage_key(:items, :tags), data[:item].scoped_field, ActiveSupport::JSON.encode(tag_array)
    end
  
    #
    #
    def buddy_get(type, limit = nil)    
      if type == :tags
        TagBuddy::Query.tags(self, limit)
      else
        TagBuddy::Query.collection(self, type, limit)
      end
    end
    
    # Create and return the storage key for the calling resource.
    # Namespace and scoping field is applied.
    #
    def storage_key(*args)
      args = args.unshift(self.send(self.class.scope_by_field))
      self.class.storage_key(*args)
    end

    # Return the field we are scoping on for this model instance.
    #
    def scoped_field
      self.send(self.class.scope_by_field)
    end
  
  
    module ClassMethods

      def define_tag_strategy(opts={})
        opts[:scope_by_field] ||= ""
        self.scope_by_field = opts[:scope_by_field].to_s
      end

      # Create and return the storage for the calling class.
      # Note the keys are namepsaced the calling class.
      #
      def storage_key(*args)
        args.unshift(
          self.namespace,
        ).map! { |v| 
          v.to_s.gsub(StorageDeliminator, "") 
        }.join(StorageDeliminator)
      end
      
      
    end # ClassMethods
      
  
  end # Base
  
  
  
end