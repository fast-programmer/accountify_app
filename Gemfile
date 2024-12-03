source "https://rubygems.org"
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby "3.1.6"

gem "rails", "7.0.8.6"

gem "sinatra"

gem "puma"

gem "pg"
gem "activerecord"

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
