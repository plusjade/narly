module TagBuddy
  
  def self.init
    Dir[File.join(File.dirname(__FILE__), %W(modules ** *.rb))].each do |f|
      require f
    end
  end
  
end # TagBuddy