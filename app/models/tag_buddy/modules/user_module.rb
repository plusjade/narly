module TagBuddy

  module User
    include TagBuddy::Base
    
    def self.included(model)
      model.extend(TagBuddy::Base::ClassMethods)
      model.extend(ClassMethods)
      class << model; attr_accessor :namespace, :scope_by_field end
      model.namespace = "USER"
    end
    
    # Get items tagged by this user.
    #
    def items(limit = nil)
      items = $redis.smembers(self.storage_key(:items))
      items = items[0, limit.to_i] unless limit.to_i.zero?
      items
    end
    
    # Get items tagged by this user with a particular tag or set of tags.
    # tags is a single or an array of Tag instances
    #
    def items_by_tags(tags, limit = nil)
      tags = Array(tags)
      keys = tags.map { |tag| self.storage_key_for_tag_items(tag.scoped_field) }

      items = $redis.send(:sinter, *keys)
      items = items[0, limit.to_i] unless limit.to_i.zero?
      items
    end

    # Get a count of items tagged with given tag by the given user
    # Tag is a single Tag instance
    #
    def items_count(tag)
      $redis.zscore self.storage_key(:tags), tag.scoped_field
    end

    def tags(limit=nil)
      self.tags_data(limit)
    end

    # broken
    #def tags_on_item(item)
    #  tags_on_item_as_array(item).map do |name|
    #    self.new(:name => name)
    #  end
    #end

    def tags_on_item_as_array(item)
      tag_array = $redis.hget self.storage_key(:items, :tags), item.scoped_field
      tag_array = tag_array ? ActiveSupport::JSON.decode(tag_array) : []

      tag_array.sort!
    end

    def storage_key_for_tag_items(tag)
      storage_key(:tag, tag, :items)
    end
    
    
    module ClassMethods


    end
    
    
  end
  
  
end