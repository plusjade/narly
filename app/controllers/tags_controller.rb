class TagsController < ApplicationController

  def index
    @tags = Tag.top_tags(:limit => 125)
    
    respond_to do |format|
      format.json do
        data = Owner.new.as_json
        data["tags"] = @tags
        
        render :json => @tags
      end
      
      format.any do
        
      end
    end
    
    
  end
  
  def show
    
  end
  
end
