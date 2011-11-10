class TagsController < ApplicationController

  def index
    @tags = Tag.taylor_get(:limit => 100)
  end
  
  def show
    
  end
  
end
