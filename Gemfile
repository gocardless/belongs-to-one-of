# frozen_string_literal: true

source "https://rubygems.org"

gemspec

gem "activerecord", "~> #{ENV['RAILS_VERSION']}" if ENV["RAILS_VERSION"]

group :test, :development do
  gem "bundler"
  gem "gc_ruboconfig", "~> 5"
  gem "pry-byebug"
  gem "rspec", "~> 3.9"
  gem "rspec_junit_formatter", "~> 0.4"

  # For integration testing
  gem "sqlite3", "~> 2"
end
