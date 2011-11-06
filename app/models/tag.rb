class Tag
  include TagBuddy::Tag
  attr_accessor :name, :total_count, :relative_count

  BlackList = /[^a-z 0-9 + # - .]/

  define_tag_strategy :namespace => "TAG", :scope_by_field => :name

  def initialize(attrs={})
    attrs[:name] = attrs[:name].to_s.downcase.gsub(BlackList, "")

    attrs.each do |k, v|
      if self.respond_to?("#{k}=")
        self.send("#{k}=", v)
      end
    end

    raise "tag cant be blank" if self.name.blank?
  end
  
end