module TagBuddy
  
  module Item
    include TagBuddy::Base
    
    def self.included(model)
      model.extend(TagBuddy::Base::ClassMethods)
      class << model; attr_accessor :namespace, :scope_by_field end
      model.namespace = "ITEM"
    end
    
    # Return items that share this item's top 3 tags.  
    # Ideally we want what items share the top 3 tags in *their* top n tags
    # but that's kind of hard right now.
    #
    def similar_items(limit=nil)
      keys = tags(3).map {|tag| tag.storage_key(:items) }
      items = $redis.send(:sinter, *keys)
      items.delete(self.items.to_s)
      items = items[0, limit.to_i] unless limit.to_i.zero?
    end
    
  end # User
  
end # TagBuddy