module ReposHelper
  
  def repo_css_id(repo)
    "repo-#{repo.full_name}".gsub("/", "-")
  end
  
end
