source "https://rubygems.org"
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby "3.2.2"

gem "rails", "~> 7.0.6"

# The original asset pipeline for Rails [https://github.com/rails/sprockets-rails]
gem "sprockets-rails"

gem "puma", "~> 5.0"

group :development, :test do
  gem "pry-byebug", "~> 3.10"
end

group :development do
end

gem "pg", "~> 1.5"
gem "activerecord", "~> 7.0"

gem "outboxer", path: "../outboxer"

# gem 'outboxer', '~> 0.1.0'

gem "sidekiq", "~> 7.1"
