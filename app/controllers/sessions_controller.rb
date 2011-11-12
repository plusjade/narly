class SessionsController < ApplicationController
  
  def create
    auth = request.env["omniauth.auth"]
    user = User.first(:provider => auth["provider"], :login => auth["extra"]["user_hash"]["login"]) || User.create_with_omniauth(auth)
    session[:user_id] = user.id
    redirect_to user_path(user.login), :notice => "Signed in!"
  end
        
  def destroy
    session[:user_id] = nil
    redirect_to root_url, :notice => "Signed out!"
  end

end
