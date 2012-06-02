require 'test_helper'

class TestInitialization < Test::Unit::TestCase
  
  test "should return initialized client object" do
    assert_not_nil SalesforceBulk::Client.new
  end
  
  test "should define default options if none provided" do
    client = SalesforceBulk::Client.new
    
    assert_equal client.host, 'login.salesforce.com'
    assert_equal client.version, '24.0'
    assert_equal client.debugging, false
  end
  
  test "should accept various options" do
    options = {
      :username => 'username',
      :password => 'password',
      :token => 'token',
      :debugging => true
    }
    
    client = SalesforceBulk::Client.new(options)
    
    assert_equal client.username, 'username'
    assert_equal client.password, 'passwordtoken'
    assert_equal client.token, 'token'
    assert_equal client.debugging, true
  end
  
  test "should authorize and return successful response" do
    options = {
      :username => 'username',
      :password => 'password',
      :token => 'token'
    }
    
    client = SalesforceBulk::Client.new(options)
    
    headers = {'Content-Type' => 'text/xml', 'SOAPAction' => 'login'}
    request = fixture("login_request.xml")
    response = fixture("login_response.xml")
    
    stub_request(:post, "https://#{client.host}/services/Soap/u/24.0")
      .with(:body => request, :headers => headers)
      .to_return(:body => response, :status => 200)
    
    client.authenticate()
    
    assert_requested :post, "https://#{client.host}/services/Soap/u/24.0", :body => request, :headers => headers, :times => 1
    
    assert_equal client.instance_host, 'na9-api.salesforce.com'
    assert_equal client.instance_variable_get('@session_id'), 
                 '00DE0000000YSKp!AQ4AQNQhDKLMORZx2NwZppuKfure.ChCmdI3S35PPxpNA5MHb3ZVxhYd5STM3euVJTI5.39s.jOBT.3mKdZ3BWFDdIrddS8O'
  end
  
  test "should parse instance id from server url" do
    client = SalesforceBulk::Client.new
    
    
    assert_equal client.instance_id('https://na1-api.salesforce.com'), 'na1-api'
    assert_equal client.instance_id('https://na23-api.salesforce.com'), 'na23-api'
    assert_equal client.instance_id('https://na345-api.salesforce.com'), 'na345-api'
    
    # protocol shouldn't matter, its just part of the host name we are after
    assert_equal client.instance_id('://na1-api.salesforce.com'), 'na1-api'
  end
  
end