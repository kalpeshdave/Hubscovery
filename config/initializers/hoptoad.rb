HoptoadNotifier.configure do |config|
  config.api_key = {
    :project => 'hubscovery',
    :tracker => 'Bug',
    :api_key => ENV['REDMINE_API_KEY'] || 'Xqa2IvqyB6vKYSlh9dsn',
    :category => 'Development',
    :assigned_to => 'jeff',
    :priority => 5
  }.to_yaml
  config.host = 'cp.thequeue.net/'
  config.port = 443
  config.secure = true
end
