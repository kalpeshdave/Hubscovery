source 'http://rubygems.org'

gem 'rails', '3.0.7'
gem 'sqlite3'

gem "haml", ">= 3.0.0"
gem "haml-rails"
gem "jquery-rails"
gem "httparty"
gem "dalli"

group :development do
  gem 'unicorn'
  gem 'capistrano'
end

group :development, :test do
  gem "capybara", :group => [:development, :test]
  gem "rspec-rails", ">= 2.0.1", :group => [:development, :test]
end
