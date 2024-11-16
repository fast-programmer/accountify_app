require 'sidekiq'
require_relative 'environment'

Sidekiq.configure_server do |config|
  config.redis = { url: ENV['REDIS_URL'] || 'redis://localhost:6379/0' }

  config.concurrency = 10

  config.logger.level = Logger::DEBUG
  config.logger.formatter = Sidekiq::Logger::Formatters::Pretty.new
end

Sidekiq.configure_client do |config|
  config.redis = { url: ENV['REDIS_URL'] || 'redis://localhost:6379/0' }
end
