source 'https://rubygems.org'

require 'pp'

gem 'rake'
gem 'dotenv'
gem 'bcrypt', '~> 3.1.7'
gem 'pg', '~> 0.18'
gem 'sinatra'
gem 'sinatra-contrib'
gem 'sinatra-active-model-serializers'
gem 'sinatra-activerecord'
gem 'sinatra-bootstrap'
gem 'slim'

group :development, :test do
  gem 'rack-test'
  gem 'rspec'
  gem 'factory_bot', '~> 4.0'
  gem 'fakefs', require: 'fakefs/safe'
  gem 'database_cleaner'
  gem 'simplecov'
end

group :test do
  gem 'capybara'
  gem 'poltergeist'
end