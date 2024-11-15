source "https://rubygems.org"
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby "3.3.0"

gem "rails"

gem "sinatra"

gem "puma"

gem "pg"
gem "activerecord"

# gem 'outboxer', '1.0.0.pre.beta'
gem 'outboxer', git: 'https://github.com/fast-programmer/outboxer.git', branch: 'master'

gem "sidekiq"

group :development do
end

group :test do
  gem 'database_cleaner-active_record'
end

group :development, :test do
  gem "pry-byebug"
  gem 'rspec-rails'
  gem 'factory_bot_rails'
end
