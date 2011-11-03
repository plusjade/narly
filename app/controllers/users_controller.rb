class UsersController < ApplicationController

  def show
    @owner = User.first!(:login => params[:login])
    
    @tag_filters = Tag.new_from_tag_string(params[:tags])
    @tag_filters = [Tag.new(:name => "watched")] if @tag_filters.blank?
    @repos = @owner.repos_by_tags(@tag_filters, 100)

    # get these last in case the owner.repos call spawns defaults
    @tags = @owner.tags
  end

  def tag
    if current_user
      @repo = Repository.first!(:ghid => params[:repo][:ghid])
      Tag.new_from_tag_string(params[:tag]).each do |tag|
        current_user.tag_repo(@repo, tag)
      end
      
      render :json => {
        :status => "good", 
        :message => "Repo Tagged!"
      }
    else
      render :json => {
        :status => "bad", 
        :message => "Please login"
      }
    end
  end

  # Return tags current_user has on given repo
  #
  def repo_tags
    @owner = User.first!(:login => params[:login])
    @repo = Repository.first!(:ghid => params[:ghid])
    @tags = @owner.tags_on_repo(@repo)
    render :json => @tags
  end
  
end
