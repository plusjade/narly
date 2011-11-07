module TagBuddy
  
  module Utilities

    # Determine the resource type from an object or Array of objects.
    # The type can be nil if the resource is nil
    # which will happen if the conditions have been omitted.
    # Note: 
    #  Note we try the object then we try the class
    #  This is because its possible to pass the class around as a type. 
    #
    def self.get_type(resource)
      sample_resource = resource.is_a?(Array) ? resource.first : resource
      if sample_resource.nil?
        type = nil  
      elsif TagBuddy.resource_models.has_value?(sample_resource)
        type = TagBuddy.resource_models.key(sample_resource)
        "#{type}s".to_sym
      elsif TagBuddy.resource_models.has_value?(sample_resource.class)
        type = TagBuddy.resource_models.key(sample_resource.class)
        "#{type}s".to_sym
      else
        raise "Invalid via type: #{type}"
      end
      
      type
    end

  end # Utilities

end # TagBuddy