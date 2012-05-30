require 'rubygems'
require 'test/unit'
require 'shoulda'
require 'mocha'
require 'webmock/test_unit'
require 'salesforce_bulk'

class Test::Unit::TestCase
  
  def self.test(name, &block)
    define_method("test #{name.inspect}", &block)
  end
  
  def api_url(client)
    "https://#{@client.host}/services/async/#{@client.version}/"
  end
  
  def bypass_authentication(client)
    client.instance_variable_set('@session_id', '123456789')
    client.instance_variable_set('@host', 'na9.salesforce.com')
    client.instance_variable_set('@instance_host', 'na9.salesforce.com')
  end
  
  def fixture_path
    File.expand_path("../fixtures", __FILE__)
  end
  
  def fixture(file)
    File.new(fixture_path + '/' + file).read
  end
  
end