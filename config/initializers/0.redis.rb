
redis = YAML.load(File.open(File.join('config','redis.yml')))

$redis = Redis.new({
  :host => redis[Rails.env]["server"]["internal"],
  :port => 6379  
})
