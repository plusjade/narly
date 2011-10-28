class HomeController < ApplicationController

  def index
    params[:username] ||= "plusjade"
    @user = GitHub.user(params[:username])
  end

end
