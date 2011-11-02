class UsersController < ApplicationController

  def show
    @owner = User.first!(:login => params[:login])
    
    @tag_filters = Tag.new_from_tag_string(params[:tags])
    @tag_filters = [Tag.new(:name => "watched")] if @tag_filters.blank?
    @repos = @owner.repos_by_tags(@tag_filters, 100)

    # get these last in case the owner.repos call spawns defaults
    @tags = @owner.tags
  end
  
end
