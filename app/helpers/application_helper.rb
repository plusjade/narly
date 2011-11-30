module ApplicationHelper

  def require_js_url
    Rails.env.production? ? "https://s3.amazonaws.com/narly/assets/require-js-build" : "/assets/require-js"
  end
end
