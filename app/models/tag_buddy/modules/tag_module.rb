module TagBuddy

  module Tag
    include TagBuddy::Base
    
    def self.included(model)
      model.extend(TagBuddy::Base::ClassMethods)
      model.extend(ClassMethods)
      
      class << model; attr_accessor :namespace, :scope_by_field end
      model.namespace = "TAG"
    end
    
  end # Tag
  
end # TagBuddy