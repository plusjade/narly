class ReposController < ApplicationController

  # Top repos are basically the index view with no tag filters.
  # TODO: 
  #   Make this work, right now we just return dummy data so the app wont break.
  #
  def top
    @tag_filters = []
    @repos = Repo.taylor_get_as_resource(:via => @tag_filters, :limit => 25)
    
    @data = Owner.new().as_json
    @data["repos"] = @repos.as_json(:methods => [:tags])
    
    respond_to do |format|
      format.json do
        render :json => @data
      end
      
      format.any do
        @tags = Tag.top_tags(:limit => 50)
        render :template => "repos/index"
      end
    end
    
  end
  
  def index
    @tag_filters = Tag.new_from_tag_string(params[:tags])
    @repos = Repo.taylor_get_as_resource(:via => @tag_filters, :limit => 25)
    
    @data = Owner.new().as_json
    @data["repos"] = @repos.as_json(:methods => [:tags])
    
    respond_to do |format|
      format.json do
        render :json => @data
      end
      
      format.any do
        @tags = Tag.top_tags(:limit => 50)
      end
    end
  end
  
  def show
    @owner = Owner.first!(params[:repo_login])
    @repo = Repo.first!("#{@owner.login}/#{params[:repo_name]}")
    @similar_repos = @repo.similar(:limit => 10)
    
    @tags = @repo.tags
    
    @data = @repo.as_json(:methods => [:tags])
    @data["similar_repos"] = @similar_repos.as_json(:methods => [:tags])
    @data["users"] = @repo.users(:limit => 25)
    
    respond_to do |format|
      format.json do

        
        render :json => @data
      end
      
      format.any do

      end
    end
    
  end
  
  def tags
    @repo = Repo.first!("#{params[:repo_login]}/#{params[:repo_name]}")
    render :json => @repo.tags(:limit => 10)
  end
  
end
