require 'coveralls'
Coveralls.wear!

require 'salesforce_bulk'
require 'webmock/rspec'

RSpec.configure do |config|
  config.mock_with :rspec
  config.order = 'random'
  config.filter_run_excluding skip: true
end