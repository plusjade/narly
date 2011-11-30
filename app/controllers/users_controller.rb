class UsersController < ApplicationController

  def show
    @owner = Owner.first!(params[:login])
    @tag_filters = Tag.new_from_tag_string(params[:tags])
    
    @repos = @owner.repos(:via => @tag_filters, :limit => 25)
    @tags = @owner.tags # get these last in case the owner.repos call spawns defaults
    
    @data = @owner.as_json(:methods =>[:tags])
    @data["repos"] = @repos.as_json(:methods => [:tags])
    
    respond_to do |format|
      format.json do
        render :json => @data
      end
      
      
      format.any do
        
      end
      
    end
    
  end

  def profile
    @owner = Owner.first!(params[:login])
    
    respond_to do |format|
      format.json do
        render :json => @owner
      end
      
      
      format.any do
        
      end
      
    end
    
  end
  
  def tag
    if current_user
      @repo = Repo.first!(params[:repo][:full_name])
      Tag.new_from_tag_string(params[:tag]).each do |tag|
        current_user.owner.taylor_tag(@repo, tag)
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

  def untag
    if current_user
      repo = Repo.first!(params[:repo][:full_name])
      Tag.new_from_tag_string(params[:tag]).each do |tag|
        current_user.owner.taylor_untag(repo, tag)
      end
      
      render :json => {
        :status => "good", 
        :message => "Tag removed!"
      }
    else
      render :json => {
        :status => "bad", 
        :message => "Please login"
      }
    end
  end

  def tags
    @user = Owner.first!(params[:login])
    render :json => @user.tags
  end
  
  # Return tags current_user has on given repo
  #
  def repo_tags
    @owner = Owner.first!(params[:login])
    @repo = Repo.first!("#{params[:repo_login]}/#{params[:repo_name]}")
    render :json => @owner.taylor_get(:tags, :via => @repo).map {|name| Tag.new(:name => name) }
  end
  
end
