require "modules/query_module.rb"
require "modules/utilities_module.rb"

module TagBuddy
  class << self; attr_accessor :resource_models ; end

  StorageDeliminator = ":"
  ValidTypes = [:items, :tags, :users]
  
  @@resource_namespaces = {
    :items => "ITEMS", 
    :tags => "TAGS", 
    :users => "USERS"
  }

  def self.resource_namespaces
    @@resource_namespaces
  end
  
  def self.resource_namespaces=(sides) 
    @@resource_namespaces = resource_namespaces
  end
    

  
  # These are instance methods that get included on all 3 models.
  #
  module Base

    def self.included(model)
      model.extend(ClassMethods)
      class << model; attr_accessor :buddy_named_scope end
    end

    # Record everything needed to make user<->rep tag associations.
    # We use redis to store associations and counts relative to those associations.
    #
    # Notes:
    #   $redis.sadd returns bool for singular value additions.
    #   Bool value reflects whether the insertion was newly added.
    #
    def buddy_tag(*args)
      args << self
      data = {}

      args.each { |o| data[TagBuddy.resource_models.key(o.class)] = o }

      # Add ITEM to the USER'S total ITEM data relative to TAG
      is_new_tag_on_item_for_user = ($redis.sadd data[:user].storage_key(:tag, data[:tag].buddy_named_scope, :items), data[:item].buddy_named_scope)

      $redis.multi do
        # Add ITEM to the USERS's total ITEM data.
        $redis.sadd data[:user].storage_key(:items), data[:item].buddy_named_scope

        # Add USER to the ITEM's total USER data
        $redis.sadd data[:item].storage_key(:users), data[:user].buddy_named_scope

        # Add USER to the TAG's total USER data.
        $redis.sadd data[:tag].storage_key(:users), data[:user].buddy_named_scope

        # Add ITEM to the TAG's total ITEM data.
        $redis.sadd data[:tag].storage_key(:items), data[:item].buddy_named_scope

        if is_new_tag_on_item_for_user
          # Increment the USER's TAG count for TAG
          $redis.zincrby data[:user].storage_key(:tags), 1, data[:tag].buddy_named_scope

          # Increment the ITEM's TAG count for TAG
          $redis.zincrby data[:item].storage_key(:tags), 1, data[:tag].buddy_named_scope
        end

        # Add TAG to total TAG data
        $redis.zincrby data[:tag].class.storage_key(:tags) , 1, data[:tag].buddy_named_scope

      end

      # Add TAG to USER's tag data relative to ITEM
      # (this is kept in a dictionary to save memory)
      tags_array = data[:user].buddy_get(:tags, :via => data[:item], :with_scores => false)
      tags_array.push(data[:tag].buddy_named_scope).uniq!
      $redis.hset data[:user].storage_key(:items, :tags), data[:item].buddy_named_scope, ActiveSupport::JSON.encode(tags_array)

    end

    # Record everything needed to remove user<->item tag associations.
    # We use redis to store associations and counts relative to those associations.
    #
    # Notes:
    #   $redis.srem returns bool for singular value additions.
    #   Bool value reflects whether the the key exist before it was removed.
    #
    def buddy_untag(*args)
      args << self
      data = {}
      args.each { |o| data[TagBuddy.resource_models.key(o.class)] = o }

      # Remove ITEM from the USER'S total ITEM data relative to TAG
      was_removed_tag_on_item_for_user = ($redis.srem data[:user].storage_key(:tag, data[:tag].buddy_named_scope, :items), data[:item].buddy_named_scope)

      $redis.multi do
        # Remove ITEM from the USERS's total ITEM data.
        $redis.srem data[:user].storage_key(:items), data[:item].buddy_named_scope

        # Remove USER from the ITEM's total USER data
        $redis.srem data[:item].storage_key(:users), data[:user].buddy_named_scope

        # Remove USER from the TAG's total USER data.
        $redis.srem data[:tag].storage_key(:users), data[:user].buddy_named_scope

        # Remove ITEM from the TAG's total ITEM data.
        $redis.srem data[:tag].storage_key(:items), data[:item].buddy_named_scope
      end

      if was_removed_tag_on_item_for_user
        # Decrement the USER's TAG count for TAG
        if($redis.zincrby data[:user].storage_key(:tags), -1, data[:tag].buddy_named_scope).to_i <= 0
          $redis.zrem data[:user].storage_key(:tags), data[:tag].buddy_named_scope
        end

        # Decrement the ITEM's TAG count for TAG
        if ($redis.zincrby data[:item].storage_key(:tags), -1, data[:tag].buddy_named_scope).to_i <= 0
          $redis.zrem data[:item].storage_key(:tags), data[:tag].buddy_named_scope
        end
      end

      # Decrement TAG count in TAG data
      if ($redis.zincrby data[:tag].class.storage_key(:tags), -1, data[:tag].buddy_named_scope).to_i <= 0
        $redis.zrem data[:tag].class.storage_key(:tags), data[:tag].buddy_named_scope
      end

      # REMOVE TAG from USER's tag data relative to ITEM
      # (this is kept in a dictionary to save memory)
      tags_array = data[:user].buddy_get(:tags, :via => data[:item], :with_scores => false)
      tags_array.delete(data[:tag].buddy_named_scope)
      $redis.hset data[:user].storage_key(:items, :tags), data[:item].buddy_named_scope, ActiveSupport::JSON.encode(tags_array)
    end

    # This is the main and recommended public interface for querying resources. 
    # Note:
    #   This method's Instance type determines the implied *scope* for this query.
    #
    # @param [:users, :items, :tags] response_type
    #   Type of resource we expect to return.
    # @param [Hash] conditions 
    #   Optional hash of conditions for filtering, limits, etc.
    #
    # @return [Array]
    # Returns and array of named_scopes of the type "response_type"
    #
    # @example
    #
    #   This will get all tags made by @user.
    #     @user.buddy_get(:tags)
    #    
    #   This will get the top 10 tags made by user on @item
    #     @user.buddy_get(:tags, :via => @item, :limit => 10) 
    #
    # Please see TagBuddy::Query.dispatch for further documentation.
    #
    def buddy_get(response_type, conditions={})
      conditions[:scope] = self
      TagBuddy::Query.dispatch(response_type, conditions)
    end

    # Create and return the storage key for the calling resource.
    # Namespace and scoping field is applied.
    #
    def storage_key(*args)
      args.map! { |v|
        TagBuddy.resource_namespaces[v] || v
      }.unshift(self.buddy_named_scope)
      
      self.class.storage_key(*args)
    end

    # Return the field we are scoping on for this model instance.
    #
    def buddy_named_scope
      self.send(self.class.buddy_named_scope)
    end


    module ClassMethods

      def define_tag_strategy(opts={})
        opts[:named_scope] ||= ""
        self.buddy_named_scope = opts[:named_scope].to_s
        resource_type = opts[:resource].to_s.downcase.to_sym

        if ValidTypes.include?("#{resource_type}s".to_sym)
          TagBuddy.resource_models[resource_type] = self
        else
          raise "Invalid Resource type"
        end
      end

      # This is the class-level public interface for querying resources.
      # Note: 
      #   This method's Class determines the implied *response_type* for this query.
      #
      # @param [:users, :items, :tags] response_type
      #   Type of resource we expect to return.
      # @param [Hash] conditions 
      #   Optional hash of conditions for filtering, limits, etc.
      #
      # @return [Array]
      # Returns an array of named_scopes of the type *response_type*
      #
      # @example
      #
      #   This will get all tags.
      #     Tag.buddy_get
      #    
      #   This will get the top 10 tags on this @item
      #     Tag.buddy_get(:via => @item, :limit => 10) 
      #
      # Please see TagBuddy::Query.dispatch for further documentation.
      #
      def buddy_get(conditions={})
        conditions[:scope] = self
        TagBuddy::Query.dispatch(TagBuddy::Utilities.get_type(self), conditions)
      end

      # Create and return the storage for the calling class.
      # Note the keys are namepsaced with the calling class resource_type.
      #
      def storage_key(*args)
        args.unshift(
        TagBuddy.resource_namespaces[TagBuddy::Utilities.get_type(self)],
        ).map! { |v| 
          v.to_s.gsub(StorageDeliminator, "") 
        }.join(StorageDeliminator)
      end

    end # ClassMethods


  end # Base


  
end # TagBuddy