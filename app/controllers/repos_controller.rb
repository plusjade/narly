class ReposController < ApplicationController

  def show
    @owner = User.first!(:login => params[:login].to_s)
    @repo = Repository.first!({
      :login => @owner.login, 
      :name => params[:name].to_s
    })
  end
  
end
