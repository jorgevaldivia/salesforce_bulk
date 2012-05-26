require 'test_helper'
require 'salesforce_bulk'

class TestInitialization < Test::Unit::TestCase
  
  test "should return initialized client object" do
    assert_not_nil SalesforceBulk::Client.new
  end
  
  test "should define default options if none provided" do
    client = SalesforceBulk::Client.new
    
    assert_equal client.host, 'login.salesforce.com'
    assert_equal client.version, '23.0'
  end
  
  test "should accept various options" do
    options = {
      :username => 'username',
      :password => 'password',
      :token => 'token'
    }
    
    client = SalesforceBulk::Client.new(options)
    
    assert_equal client.username, 'username'
    assert_equal client.password, 'password'
    assert_equal client.token, 'token'
  end
  
end