require 'simplecov'
require 'coveralls'

SimpleCov.formatter = Coveralls::SimpleCov::Formatter
SimpleCov.start do
  add_filter 'spec'
end

require 'salesforce_bulk'
require 'webmock/rspec'

RSpec.configure do |config|
  config.mock_with :rspec
  config.order = 'random'
  config.filter_run_excluding skip: true
end