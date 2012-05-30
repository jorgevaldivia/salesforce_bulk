require 'test_helper'

class TestJob < Test::Unit::TestCase
  
  def setup
    options = {
      :username => 'myusername', 
      :password => 'mypassword',
      :token => "somelongtoken"
    }
    
    @client = SalesforceBulk::Client.new(options)
  end
  
  test "should return initialized job object" do
    job = @client.job(:upsert, :VideoEvent__c, :Id__c)
    
    assert_not_nil job
    
    assert_equal job.operation, :upsert
    assert_equal job.sobject, :VideoEvent__c
    assert_equal job.externalIdFieldName, :Id__c
    assert_equal job.concurrencyMode, :parallel
  end
  
  test "should create job and return successful response" do
    bypass_authentication(@client)
    
    headers = {'Content-Type' => 'application/xml', 'X-Sfdc-Session' => '123456789'}
    request = fixture("job_create_request.xml")
    response = fixture("job_create_response.xml")
    
    stub_request(:post, "#{api_url(@client)}job")
      .with(:body => request, :headers => headers)
      .to_return(:body => response, :status => 200)
    
    job = @client.job(:upsert, :VideoEvent__c, :Id__c)
    job.create
    
    assert_requested :post, "#{api_url(@client)}job", :body => request, :headers => headers, :times => 1
    
    assert_equal job.id, '750E00000004MzbIAE'
    assert_equal job.state, 'Open'
  end
  
  test "should close job and return successful response" do
    bypass_authentication(@client)
    
    headers = {'Content-Type' => 'application/xml', 'X-Sfdc-Session' => '123456789'}
    request = fixture("job_close_request.xml")
    response = fixture("job_close_response.xml")
    jobId = "750E00000004MzbIAE"
    
    stub_request(:post, "#{api_url(@client)}job/#{jobId}")
      .with(:body => request, :headers => headers)
      .to_return(:body => response, :status => 200)
    
    job = @client.job(:upsert, :VideoEvent__c, :Id__c)
    job.instance_variable_set("@id", jobId)
    job.close
    
    assert_requested :post, "#{api_url(@client)}job/#{jobId}", :body => request, :headers => headers, :times => 1
    
    assert_equal job.id, jobId
    assert_equal job.state, 'Closed'
  end
  
  test "should abort job and return successful response" do
    bypass_authentication(@client)
    
    headers = {'Content-Type' => 'application/xml', 'X-Sfdc-Session' => '123456789'}
    request = fixture("job_abort_request.xml")
    response = fixture("job_abort_response.xml")
    jobId = "750E00000004N1NIAU"
    
    stub_request(:post, "#{api_url(@client)}job/#{jobId}")
      .with(:body => request, :headers => headers)
      .to_return(:body => response, :status => 200)
    
    job = @client.job(:upsert, :VideoEvent__c, :Id__c)
    job.instance_variable_set("@id", jobId)
    job.abort
    
    assert_requested :post, "#{api_url(@client)}job/#{jobId}", :body => request, :headers => headers, :times => 1
    
    assert_equal job.id, jobId
    assert_equal job.state, 'Aborted'
  end
  
end