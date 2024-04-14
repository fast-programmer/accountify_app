require 'sidekiq'

Sidekiq.configure_server do |config|
  config.logger = Logger.new($stdout, level: Logger::DEBUG)
end

Sidekiq.configure_client do |config|
  config.logger = Logger.new($stdout, level: Logger::DEBUG)
end
