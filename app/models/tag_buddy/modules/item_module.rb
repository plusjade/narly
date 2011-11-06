module TagBuddy
  
  module Item
    include TagBuddy::Base
    
    def self.included(model)
      model.extend(TagBuddy::Base::ClassMethods)
      model.extend(ClassMethods)
      class << model; attr_accessor :namespace, :scope_by_field end
      model.namespace = "ITEM"
    end
    
    # Return an Array of Tag instances associated with this Repo.
    # Tags become associated with a repo when a user tags said repo.
    #
    def tags(limit=nil)
      self.tags_data(limit)
    end

    # Return an Array of User instances this Repo is attached to.
    # A user is attached to a repo when the user tags said repo.
    #    
    def users(limit=nil)
      users = Array($redis.smembers storage_key(:users))
      users = users[0, limit.to_i] unless limit.to_i.zero?
      users
    end

    # Return an Array of Repo instances that share this repo's top 3 tags.  
    # Ideally we want what repos share the top 3 tags in *their* top n tags
    # but that's kind of hard right now.
    #
    def similar_items(limit=nil)
      keys = tags(3).map {|tag| tag.storage_key(:items) }
      items = $redis.send(:sinter, *keys)
      items.delete(self.items.to_s)
      items = items[0, limit.to_i] unless limit.to_i.zero?
    end
    
    
    module ClassMethods
      
      def tag_buddy_type
        :item
      end
        
    end # ClassMethods
    
  end # User
  
end # TagBuddy