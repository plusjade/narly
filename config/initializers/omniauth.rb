
Rails.application.config.middleware.use OmniAuth::Builder do
  creds = YAML.load(File.open(File.join('config','omniauth.yml')))
  provider :github, creds[Rails.env]["github"]["client_id"], creds[Rails.env]["github"]["client_secret"]
end