require 'test_helper'

class TestInitialization < Test::Unit::TestCase
  
  def setup
    options = {
      :username => 'username',
      :password => 'password',
      :token => 'token'
    }
    
    @client = SalesforceBulk::Client.new(options)
  end
  
  test "default option values set if none provided" do
    assert_not_nil @client
    assert_equal @client.host, 'login.salesforce.com'
    assert_equal @client.version, '24.0'
    assert_equal @client.debugging, false
  end
  
  test "overriding option defaults and providing login info" do
    options = {
      :username => 'MyUsername',
      :password => 'MyPassword',
      :token => 'MySecurityToken',
      :debugging => true,
      :host => 'newhost.salesforce.com',
      :version => '1.0'
    }
    
    client = SalesforceBulk::Client.new(options)
    
    assert_equal client.username, options[:username]
    assert_equal client.password, "#{options[:password]}#{options[:token]}"
    assert_equal client.token, options[:token]
    assert_equal client.debugging, options[:debugging]
    assert_equal client.host, options[:host]
    assert_equal client.version, options[:version]
  end
  
  test "authentication" do
    headers = {'Content-Type' => 'text/xml', 'SOAPAction' => 'login'}
    request = fixture("login_request.xml")
    response = fixture("login_response.xml")
    
    stub_request(:post, "https://#{@client.host}/services/Soap/u/24.0")
      .with(:body => request, :headers => headers)
      .to_return(:body => response, :status => 200)
    
    @client.authenticate()
    
    assert_requested :post, "https://#{@client.host}/services/Soap/u/24.0", :body => request, :headers => headers, :times => 1
    
    assert_equal @client.instance_host, 'na9-api.salesforce.com'
    assert_equal @client.instance_variable_get('@session_id'), '00DE0000000YSKp!AQ4AQNQhDKLMORZx2NwZppuKfure.ChCmdI3S35PPxpNA5MHb3ZVxhYd5STM3euVJTI5.39s.jOBT.3mKdZ3BWFDdIrddS8O'
  end
  
  test "parsing instance id from server url" do
    assert_equal @client.instance_id('https://na1-api.salesforce.com'), 'na1-api'
    assert_equal @client.instance_id('https://na23-api.salesforce.com'), 'na23-api'
    assert_equal @client.instance_id('https://na345-api.salesforce.com'), 'na345-api'
    
    # protocol shouldn't matter, its just part of the host name we are after
    assert_equal @client.instance_id('://na1-api.salesforce.com'), 'na1-api'
    assert_equal @client.instance_id('://na23-api.salesforce.com'), 'na23-api'
    
    # in fact the .com portion shouldn't matter either
    assert_equal @client.instance_id('://na1-api.salesforce'), 'na1-api'
    assert_equal @client.instance_id('://na23-api.salesforce'), 'na23-api'
  end
  
end