require 'test_helper'

class TestJob < Test::Unit::TestCase
  
  def setup
    options = {
      :username => 'myusername', 
      :password => 'mypassword',
      :token => "somelongtoken"
    }
    
    @client = SalesforceBulk::Client.new(options)
    @headers = {'Content-Type' => 'application/xml', 'X-Sfdc-Session' => '123456789'}
    
    bypass_authentication(@client)
  end
  
  test "initialization" do
    attrs = {
      'operation' => 'upsert',
      'sobject' => 'VideoEvent__c',
      'external_id_field_name' => 'Id__c',
      'concurrency_mode' => 'Parallel'
    }
    job = SalesforceBulk::Job.new(attrs)
    
    assert_not_nil job
    assert_equal job.operation, attrs['operation']
    assert_equal job.sobject, attrs['sobject']
    assert_equal job.external_id_field_name, attrs['external_id_field_name']
    assert_equal job.concurrency_mode, attrs['concurrency_mode']
  end
  
  test "initialization from XML" do
    xml = fixture("job_info_response.xml")
    job = SalesforceBulk::Job.new_from_xml(XmlSimple.xml_in(xml, 'ForceArray' => false))
    
    assert_equal job.id, '750E00000004N1mIAE'
  end
  
  test "should create job and return successful response" do
    request = fixture("job_create_request.xml")
    response = fixture("job_create_response.xml")
    
    stub_request(:post, "#{api_url(@client)}job")
      .with(:body => request, :headers => @headers)
      .to_return(:body => response, :status => 200)
    
    job = @client.add_job(:upsert, :VideoEvent__c, :external_id_field_name => :Id__c)
    
    assert_requested :post, "#{api_url(@client)}job", :body => request, :headers => @headers, :times => 1
    
    assert_equal job.id, '750E00000004MzbIAE'
    assert_equal job.state, 'Open'
  end
  
  test "should close job and return successful response" do
    request = fixture("job_close_request.xml")
    response = fixture("job_close_response.xml")
    jobId = "750E00000004MzbIAE"
    
    stub_request(:post, "#{api_url(@client)}job/#{jobId}")
      .with(:body => request, :headers => @headers)
      .to_return(:body => response, :status => 200)
    
    job = @client.close_job(jobId)
    
    assert_requested :post, "#{api_url(@client)}job/#{jobId}", :body => request, :headers => @headers, :times => 1
    
    assert_equal job.id, jobId
    assert_equal job.state, 'Closed'
  end
  
  test "should abort job and return successful response" do
    request = fixture("job_abort_request.xml")
    response = fixture("job_abort_response.xml")
    jobId = "750E00000004N1NIAU"
    
    stub_request(:post, "#{api_url(@client)}job/#{jobId}")
      .with(:body => request, :headers => @headers)
      .to_return(:body => response, :status => 200)
    
    job = @client.abort_job(jobId)
    
    assert_requested :post, "#{api_url(@client)}job/#{jobId}", :body => request, :headers => @headers, :times => 1
    
    assert_equal job.id, jobId
    assert_equal job.state, 'Aborted'
  end
  
  test "should return job info" do
    response = fixture("job_info_response.xml")
    jobId = "750E00000004N1mIAE"
    
    stub_request(:get, "#{api_url(@client)}job/#{jobId}")
      .with(:body => '', :headers => @headers)
      .to_return(:body => response, :status => 200)
    
    job = @client.job_info(jobId)
    
    assert_requested :get, "#{api_url(@client)}job/#{jobId}", :body => '', :headers => @headers, :times => 1
    
    assert_equal job.id, jobId
    assert_equal job.state, 'Open'
  end
  
  test "should raise SalesforceError on invalid job" do
    response = fixture("invalid_job_error.xml")
    
    stub_request(:post, "#{api_url(@client)}job").to_return(:body => response, :status => 500)
    
    assert_raise SalesforceBulk::SalesforceError do
      job = @client.add_job(:upsert, :SomeNonExistingObject__c, :external_id_field_name => :Id__c)
    end
  end
  
end