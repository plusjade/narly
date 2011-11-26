class ReposController < ApplicationController

  def index
    @tag_filters = Tag.new_from_tag_string(params[:tags])
    @repos = Repository.taylor_get_as_resource(:via => @tag_filters, :limit => 25)
    
    @data = User.new().as_json
    @data["repos"] = @repos.as_json(:methods => [:tags, :owner])
    
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
    @owner = User.first!(:login => params[:repo_login].to_s)
    @repo = Repository.first!({
      :login => @owner.login, 
      :name => params[:repo_name].to_s
    })
    #@similar_repos = @repo.similar(:limit => 10)
    @similar_repos = @owner.repos(:limit => 2)
    
    @tags = @repo.tags
    
    @data = @repo.as_json(:methods => [:tags, :owner])
    @data["similar_repos"] = @similar_repos.as_json(:methods => [:tags, :owner])
    
    respond_to do |format|
      format.json do

        
        render :json => @data
      end
      
      format.any do

      end
    end
    
  end
  
  def tags
    @repo = Repository.first!(:full_name => "#{params[:repo_login]}/#{params[:repo_name]}")
    render :json => @repo.tags(:limit => 10)
  end
  
end
