class ReposController < ApplicationController

  def index
    @tag_filters = Tag.new_from_tag_string(params[:tags])
    @repos = Repository.taylor_get_as_resource(:via => @tag_filters, :limit => 25)
    
    respond_to do |format|
      format.json do
        render :json => @repos.to_json(:methods => [:tags, :owner])
      end
      
      format.any do
        
      end
    end
  end
  
  def show
    @owner = User.first!(:login => params[:repo_login].to_s)
    @repo = Repository.first!({
      :login => @owner.login, 
      :name => params[:repo_name].to_s
    })
    @similar_repos = @repo.similar(:limit => 10)
  end
  
  def tags
    @repo = Repository.first!(:full_name => "#{params[:repo_login]}/#{params[:repo_name]}")
    render :json => @repo.tags(:limit => 10)
  end
  
end
