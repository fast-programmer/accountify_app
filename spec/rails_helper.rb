ENV['RAILS_ENV'] ||= 'test'

require 'spec_helper'
require 'factory_bot_rails'
require 'database_cleaner/active_record'

require_relative '../config/environment'

abort("The Rails environment is running in production mode!") if Rails.env.production?

require 'rspec/rails'

require 'sidekiq/testing'

begin
  ActiveRecord::Migration.maintain_test_schema!
rescue ActiveRecord::PendingMigrationError => e
  abort e.to_s.strip
end

RSpec.configure do |config|
  config.fixture_path = Rails.root.join('spec/fixtures')

  config.use_transactional_fixtures = false

  config.before(:each) do
    DatabaseCleaner.strategy = :truncation
  end

  config.before(:each) do
    DatabaseCleaner.clean
  end

  config.infer_spec_type_from_file_location!

  config.filter_rails_from_backtrace!

  config.default_formatter = 'documentation'

  Sidekiq.logger.level = Logger::ERROR if Rails.env.test?

  Sidekiq::Testing.fake!

  config.before(:each) do
    Sidekiq::Worker.clear_all
  end

  config.include FactoryBot::Syntax::Methods
end
