class HomeController < ApplicationController

  def index
    @tags = Tag.top_tags(:limit => 50)
  end

  def about
    
  end
  
  def stack
    
  end
  
end
