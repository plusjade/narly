class TagsController < ApplicationController

  def index
    @tags = Tag.all(100)
  end
  
  def show
    
  end
  
end
