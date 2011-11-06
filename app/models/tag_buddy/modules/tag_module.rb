module TagBuddy

  module Tag
    include TagBuddy::Base
    
    def self.included(model)
      model.extend(TagBuddy::Base::ClassMethods)
      model.extend(ClassMethods)
      
      class << model; attr_accessor :namespace, :scope_by_field end
      model.namespace = "TAG"
    end

    module ClassMethods

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

        TagBuddy::Query.items_by_tags(self, tags, limit)
      end

    end # ClassMethods
      
    
  end # Tag
  
  
end # TagBuddy