module TagBuddy

  module User
    include TagBuddy::Base
    
    def self.included(model)
      model.extend(TagBuddy::Base::ClassMethods)
      class << model; attr_accessor :namespace, :scope_by_field end
      model.namespace = "USER"
    end
    
    # Get items tagged by this user with a particular tag or set of tags.
    # tags is a single or an array of Tag instances
    #
    def items_by_tags(tags, limit = nil)
      TagBuddy::Query.items_by_tags(self, tags, limit)
    end
    
    # Get a count of items tagged with given tag by the given user
    # Tag is a single Tag instance
    #
    def items_count(tag)
      $redis.zscore self.storage_key(:tags), tag.scoped_field
    end

    def tags_on_item(item)
      TagBuddy::Query.tags_on_item(self, tags, limit)
    end
        
  end
  
  
end