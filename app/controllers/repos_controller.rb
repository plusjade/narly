class ReposController < ApplicationController

  def index
    @repos = Tag.repos(params[:tags])
  end
  
  def show
    @owner = User.first!(:login => params[:login].to_s)
    @repo = Repository.first!({
      :login => @owner.login, 
      :name => params[:name].to_s
    })
    @similar_repos = @repo.similar_repos
  end
  
end
