class ReposController < ApplicationController

  def index
    @tag_filters = Tag.new_from_tag_string(params[:tags])
    @repos = Tag.repos(@tag_filters, 25)
  end
  
  def show
    @owner = User.first!(:login => params[:login].to_s)
    @repo = Repository.first!({
      :login => @owner.login, 
      :name => params[:name].to_s
    })
    @similar_repos = @repo.similar_repos(10)
  end
  
  def tags
    @repo = Repository.new(:ghid => params[:ghid].to_i)
    render :json => @repo.tags(10)
  end
  
end
