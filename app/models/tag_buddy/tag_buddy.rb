module TagBuddy
  
  def self.init
    Dir[File.join(File.dirname(__FILE__), %W(modules ** *.rb))].each do |f|
      require f
    end
  end
  
  module Utilities

    # Determine the resource type from an object or Array of objects.
    # The type can be nil if the resource is nil
    # which will happen if the conditions have been omitted.
    # Hacky: 
    #  Note we try the object first and if :namespace is not defined
    #  we try the class. This is because its possible to pass the class
    #  around as a type. 
    #  TODO: Refactor this.
    #
    def self.get_type(resource)
      type = nil
      
      if resource.is_a?(Array)
        if resource.first.respond_to?(:namespace)
          type = "#{resource.first.namespace.downcase}s".to_sym
        elsif resource.first.class.respond_to?(:namespace)
          type = "#{resource.first.class.namespace.downcase}s".to_sym
        else
          raise "Invalid via type"
        end
      elsif resource
        if resource.respond_to?(:namespace)
          type = "#{resource.namespace.downcase}s".to_sym
        elsif resource.class.respond_to?(:namespace)
          type = "#{resource.class.namespace.downcase}s".to_sym
        else
          raise "Invalid via type"
        end
      end
      
      type
    end

  end
end # TagBuddy