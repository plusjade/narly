module TagBuddy

  module Tag
    include TagBuddy::Base
    
    def self.included(model)
      model.extend(TagBuddy::Base::ClassMethods)
      model.extend(ClassMethods)
      
      class << model; attr_accessor :namespace, :scope_by_field end
      model.namespace = "TAG"
    end
    
    # Return an Array of User instances this tag is associated with.
    # A user is attached to a tag when the user tags a repo with said tag.
    #
    def users(limit = nil)
      users = Array($redis.smembers storage_key(:users))
      users = users[0, limit.to_i] unless limit.to_i.zero?
      users
    end
        
    # Get items this tag is attached to.
    #  
    def items(limit = nil)
      items = Array($redis.smembers storage_key(:items))
      items = items[0, limit.to_i] unless limit.to_i.zero?
      items
    end
    
    module ClassMethods

      # Get all Tags
      #
      def all(limit=nil)
        self.new_from_tags_data(
          $redis.zrevrange( 
            self.namespace,
            0, 
            (limit.to_i.nil? ? -1 : limit.to_i - 1),
            :with_scores => true
          )
        )
      end
        
      
      # Spawn Tag instances from the given tag_string
      # where tag_string is a String of the format:
      #   tag1:tag2:tag3:tagN:...
      # This format is used in the url as paramater
      #
      def new_from_tag_string(tag_string)
        tag_string.to_s.split(":").map do |name|
          new(:name => name)
        end
      end

      # Return an Array of items associated with the provided tags.
      # tags can be one or an Array of Tag instances or a tag_string
      #
      def items(tags, limit = nil)
        tags = case tags
        when String
          new_from_tag_string(tags)
        else
          Array(tags)
        end

        keys = tags.map { |tag| tag.storage_key(:items) }
        items = $redis.send(:sinter, *keys)
        items = items[0, limit.to_i] unless limit.to_i.zero?
        items
      end

      # tags_data format: 
      #   ["ruby", "1", "git", "1"] 
      #   where scores represent tag count and come directly after their tag.
      #
      def new_from_tags_data(tags_data)
        tags = []
        tags_data.each_with_index do |name, i|
    			next if (i > 0 && i.odd?)
          tags << new(:name => name, :relative_count => tags_data[i+1])
        end

        tags
      end  

      # Takes one or more Tag instances (via array) and provides
      # the equivalent tag_string
      #
      def to_tag_string(tags)
        Array(tags).map! { |tag| tag.scoped_field }.join(":")
      end
        
        
    end # TagClassMethods
      
    
  end # Tag
  
  
end # TagBuddy