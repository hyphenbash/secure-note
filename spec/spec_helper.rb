ENV['RACK_ENV'] ||= 'test'

require 'simplecov'
SimpleCov.start do
  add_filter 'spec'
end #if ENV['COVERAGE']

require 'capybara/rspec'
require 'fakefs/spec_helpers'

Dir[File.expand_path 'lib/**/*.rb'].each { |f| require f }
Dir[File.expand_path 'spec/support/**/*.rb'].each { |f| require f }

Capybara.app = SecureNote::Application

RSpec.configure do |config|
  config.expect_with :rspec do |expectations|
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
  end

  config.mock_with :rspec do |mocks|
    mocks.verify_partial_doubles = true
  end

  config.shared_context_metadata_behavior = :apply_to_host_groups

  config.include FormHelpers, :type => :feature
  config.include Capybara::DSL
  config.include Capybara::RSpecMatchers
  config.include RSpecMixin
  config.include FakeFS::SpecHelpers, fakefs: true
end
