module TagBuddy
  
  module Item
    include TagBuddy::Base
    
    def self.included(model)
      model.extend(TagBuddy::Base::ClassMethods)
      class << model; attr_accessor :namespace, :scope_by_field end
      model.namespace = "ITEM"
    end
    
  end # User
  
end # TagBuddy