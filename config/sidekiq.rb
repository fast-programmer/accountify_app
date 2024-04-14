require 'sidekiq'

Sidekiq.configure_server do |config|
  config.redis = { url: ENV['REDIS_URL'] || 'redis://localhost:6379/0' }

  config.concurrency = 10
end

Sidekiq.configure_client do |config|
  config.redis = { url: ENV['REDIS_URL'] || 'redis://localhost:6379/0' }
end