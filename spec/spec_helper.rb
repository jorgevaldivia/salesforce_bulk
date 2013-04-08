require 'salesforce_bulk'

RSpec.configure do |config|
  config.mock_with :rspec
  config.order = 'random'
  config.filter_run_excluding skip: true
end