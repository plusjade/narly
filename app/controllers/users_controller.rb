class UsersController < ApplicationController

  def show
    @owner = User.first!(:login => params[:login])
    
    @tag_filters = Tag.new_from_tag_string(params[:tags])
    @tag_filters = [Tag.new(:name => "#{Tag::PersonalNamespace}watched")] if @tag_filters.blank?

    @repos = @owner.repos(:via => @tag_filters)
    @tags = @owner.tags # get these last in case the owner.repos call spawns defaults
  end

  def tag
    if current_user
      @repo = Repository.first!(:full_name => params[:repo][:full_name])
      Tag.new_from_tag_string(params[:tag]).each do |tag|
        current_user.taylor_tag(@repo, tag)
      end
      
      render :json => {
        :status => "good", 
        :message => "Repo Tagged!"
      }
    else
      render :json => {
        :status => "bad", 
        :message => "Please login"
      }
    end
  end

  def untag
    if current_user
      repo = Repository.new(:full_name => params[:repo][:full_name])
      Tag.new_from_tag_string(params[:tag]).each do |tag|
        current_user.taylor_untag(repo, tag)
      end
      
      render :json => {
        :status => "good", 
        :message => "Tag removed!"
      }
    else
      render :json => {
        :status => "bad", 
        :message => "Please login"
      }
    end
  end

  def tags
    @user = User.first!(:login => params[:login])
    render :json => @user.tags
  end
  
  # Return tags current_user has on given repo
  #
  def repo_tags
    @owner = User.first!(:login => params[:login])
    @repo = Repository.first!(:full_name => "#{params[:repo_login]}/#{params[:repo_name]}")
    render :json => @owner.tags(:via => @repo)
  end
  
end
