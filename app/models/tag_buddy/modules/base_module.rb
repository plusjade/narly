module TagBuddy

  StorageDeliminator = ":"
  ValidTypes = [:items, :tags, :users]

  # These are instance methods that get included on all 3 models.
  #
  module Base
    
    def self.included(model)
      model.extend(TagBuddy::Base::ClassMethods)
      class << model; attr_accessor :scope_by_field end
    end

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
      
      args.each { |o| data[TagBuddy.resource_models.key(o.class)] = o }
    
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
      tag_array = data[:user].tags_via(data[:item])
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
      args.each { |o| data[TagBuddy.resource_models.key(o.class)] = o }
    
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
      tag_array = data[:user].tags_via(data[:item])
      tag_array.delete(data[:tag].scoped_field)
      $redis.hset data[:user].storage_key(:items, :tags), data[:item].scoped_field, ActiveSupport::JSON.encode(tag_array)
    end
  
    # This is the main query interface for getting objects via TagBuddy.
    # type = (Symbol) in the set [:users, :items, :tags]
    # conditions = (Hash) 
    #   :via = Object or Array of objects 
    #     Specifies the object or Array of objects you want to query on.
    #     "Query on" is somewhat vague. 
    #     But I trust you can infer from the relationships how a :via condition will work.
    #     Example: @user.buddy_get(:tags, :via => @item)
    #     We expect tags to be returned since our type is :tags
    #     since we are calling buddy_get on @user 
    #     you can infer that we are trying to get "tags from @user via @item"
    #     Or put more accurately : "tags from @user on @item"
    #
    #  :limit = (Integer)
    #    Specifies the limit of objects to return
    #
    # API:
    # -----------------------------------------------------------
    # User instance
    #
    #   @user.buddy_get(:users)  # invalid
    #   @user.buddy_get(:items)  # get all items tagged by @user
    #   @user.buddy_get(:tags)   # get all tags used by @user
    # 
    #   @user.buddy_get(:users, :via => @tags) # invalid
    #   @user.buddy_get(:items, :via => @tags) # get all items tagged by @user with @tags
    #   @user.buddy_get(:tags, :via => @item) # get all tags made by @user on @item
    # 
    # Item instance 
    #
    #   @item.buddy_get(:users)  # all users that have tagged this item.
    #   @item.buddy_get(:items)  # invalid
    #   @item.buddy_get(:tags)   # all tags on this item.
    # 
    #   @item.buddy_get(:users, :via => @tags) # all users that have tagged this item with @tags.
    #   @item.buddy_get(:items, :via => @tags) # invalid
    #   @item.buddy_get(:tags, :via => @user) # all tags on @item by @user
    #
    # Tag instance
    #
    #   @tag.buddy_get(:users)  # all users that have used @tag.
    #   @tag.buddy_get(:items)  # all items tagged by @tag
    #   @tag.buddy_get(:tags)   # invalid
    # 
    #   @tag.buddy_get(:users, :via => @item) # all users that have tagged @item with @tag
    #   @tag.buddy_get(:items, :via => @user) # all items tagged @tag by @user
    #   @tag.buddy_get(:tags, :via => @user) # invalid
    #
    # [response_type] is the type of resource we expect to return
    # [self] is the resource we are scoping to.
    # [via] is the resource(s) we are filtering by.
    # [via_type] is the type of resource we are filtering by.
    #
    def buddy_get(response_type, conditions={})
      raise "Invalid type" unless ValidTypes.include?(response_type)
      via_type = TagBuddy::Utilities.get_type(conditions[:via])

      if response_type == :tags
        
        if via_type.nil?
          TagBuddy::Query.tags({
            :users => self, 
            :limit => conditions[:limit]
          })
        elsif via_type == :items
          TagBuddy::Query.tags_via({
            :users => self, 
            :items => conditions[:via], 
            :limit => conditions[:limit]
          })
        elsif via_type == :users
          TagBuddy::Query.tags_via({
            :users => conditions[:via],
            :items => self, 
            :limit => conditions[:limit]
          })
        else
          raise "Invalid via condition."
        end
        
      elsif response_type == :items
        
        if via_type.nil?
          conditions[:via] = self
          TagBuddy::Query.collection(response_type, conditions)
        elsif via_type == :tags
          TagBuddy::Query.items_via({
            :users => self,
            :tags => conditions[:via],
            :limit => conditions[:limit],
          })
        elsif via_type == :users
          TagBuddy::Query.items_via({
            :users => conditions[:via],
            :tags => self,
            :limit => conditions[:limit],
          })
        else
          raise "Invalid via condition."
        end
      
      elsif response_type == :users
        
        if via_type.nil?
          conditions[:via] = self
          TagBuddy::Query.collection(response_type, conditions)
        elsif via_type == :items
          TagBuddy::Query.users_via({
            :items => conditions[:via],
            :tags => self,
            :limit => conditions[:limit],
          })
        elsif via_type == :tags
          TagBuddy::Query.users_via({
            :items => self,
            :tags => conditions[:via],
            :limit => conditions[:limit],
          })
        else
          raise "Invalid via condition."
        end
        
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
        resource_type = opts[:resource].to_s.downcase.to_sym

        if ValidTypes.include?("#{resource_type}s".to_sym)
          TagBuddy.resource_models[resource_type] = self
        else
          raise "Invalid Resource type"
        end
      end

      # Get resources from the total collection pool for this class.
      # i.e. Tag.buddy_get would return all tags
      # i.e. User.buddy_get would return all users
      #
      # passing conditions will filter based on those conditions
      #
      # [response_type] is the type of resource we expect to return
      # [via_type] is the type of resource we are filtering by.
      # [self] is the class level resource we are scoping to.
      #
      def buddy_get(conditions={})
        response_type = TagBuddy::Utilities.get_type(self)
        via_type = TagBuddy::Utilities.get_type(conditions[:via])
        
        if response_type == :tags
          TagBuddy::Query.tags({
            :users => self, 
            :limit => conditions[:limit]
          })
        else   
          conditions[:via] = self if via_type.nil?
          TagBuddy::Query.collection(response_type, conditions)
        end

      end
      
      # Create and return the storage for the calling class.
      # Note the keys are namepsaced the calling class.
      #
      def storage_key(*args)
        args.unshift(
          TagBuddy.resource_models.key(self),
        ).map! { |v| 
          v.to_s.gsub(StorageDeliminator, "") 
        }.join(StorageDeliminator)
      end
      
    end # ClassMethods
      
  
  end # Base
  
  
  
end