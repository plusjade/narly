module ReposHelper
  
  # Make sure this matches exactly in the javascript.
  def repo_css_id(repo)
    "repo-#{repo.full_name}".gsub(/[^\w]/, "-")
  end
  
end
