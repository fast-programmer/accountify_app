source "https://rubygems.org"
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby "3.3.0"

gem "rails"

# The original asset pipeline for Rails [https://github.com/rails/sprockets-rails]
gem "sprockets-rails"

gem "puma"

group :development, :test do
  gem "pry-byebug"
end

group :development do
end

gem "pg"
gem "activerecord"

gem "outboxer", path: "../outboxer"

gem "sidekiq"

group :development, :test do
  gem 'rspec-rails'
end
