require 'sidekiq/web'
require 'outboxer/web'

if Rails.env.production?
  Sidekiq::Web.use Rack::Auth::Basic do |username, password|
    ActiveSupport::SecurityUtils.secure_compare(username, ENV['SIDEKIQ_USERNAME']) &&
      ActiveSupport::SecurityUtils.secure_compare(password, ENV['SIDEKIQ_PASSWORD'])
  end
end

Rails.application.routes.draw do
  mount Sidekiq::Web => '/sidekiq'

  mount Outboxer::Web, at: '/outboxer'
end
