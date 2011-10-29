class UsersController < ApplicationController

  def show
    params[:username] ||= "plusjade"
    @user = User.find_by_username(params[:username])
    
    unless @user
      user = GitHub.user(params[:username])

      # a nil message means the object exists.
      if user.message.nil?
        @user = User.create_with_api(user)
      end
    end
    
    raise ActiveRecord::RecordNotFound unless @user
  end
  
end
