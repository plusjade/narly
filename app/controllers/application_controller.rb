require 'dm-rails/middleware/identity_map'
class ApplicationController < ActionController::Base
  use Rails::DataMapper::Middleware::IdentityMap

  protect_from_forgery

  helper_method :current_user
  private
  def current_user
    @current_user ||= User.get(session[:user_id]) if session[:user_id]
  end

end
