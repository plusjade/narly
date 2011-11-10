source 'http://rubygems.org'

RAILS_VERSION = '~> 3.1.1'
DM_VERSION    = '~> 1.2.0'

gem 'rails', RAILS_VERSION
gem 'mysql'
gem 'redis', '2.1.1'
gem 'taylor-swift', '0.1.0', :path => "~/Dropbox/gems/taylor-swift"

gem 'activesupport',      RAILS_VERSION, :require => 'active_support'
gem 'actionpack',         RAILS_VERSION, :require => 'action_pack'
gem 'actionmailer',       RAILS_VERSION, :require => 'action_mailer'
gem 'railties',           RAILS_VERSION, :require => 'rails'
gem 'tzinfo'

gem 'dm-rails',             DM_VERSION
gem 'dm-mysql-adapter',     DM_VERSION
gem 'dm-migrations',        DM_VERSION
gem 'dm-types',             DM_VERSION
gem 'dm-validations',       DM_VERSION
gem 'dm-constraints',       DM_VERSION
gem 'dm-transactions',      DM_VERSION
gem 'dm-aggregates',        DM_VERSION
gem 'dm-timestamps',        DM_VERSION
gem 'dm-observer',          DM_VERSION
gem 'dm-serializer',        DM_VERSION

gem 'omniauth'
gem 'httparty'

gem 'execjs'
gem 'therubyracer'

# Gems used only for assets and not required
# in production environments by default.
group :assets do
  gem 'sass-rails', "  ~> 3.1.0"
  gem 'coffee-rails', "~> 3.1.0"
  gem 'uglifier'
end

gem 'jquery-rails'

# Use unicorn as the web server
# gem 'unicorn'

# Deploy with Capistrano
# gem 'capistrano'

# To use debugger
# gem 'ruby-debug19', :require => 'ruby-debug'
group :development do
  gem "wirble"
  gem "hirb"  
end

group :test do
  # Pretty printed test output
  gem 'turn', :require => false
end
