require 'test_helper'

class TestBatch < Test::Unit::TestCase
  
  def setup
    options = {
      :username => 'myusername', 
      :password => 'mypassword',
      :token => "somelongtoken"
    }
    
    @client = SalesforceBulk::Client.new(options)
    @batch = SalesforceBulk::Batch.new
  end
  
  test "state?" do
    @batch.state = "Completed"
    assert @batch.state?('Completed')
    
    @batch.state = "COMPLETED"
    assert @batch.state?('completed')
    
    @batch.state = "Failed"
    assert !@batch.state?('Queued')
  end
  
  test "state is marked queued" do
    @batch.state = "Queued"
    assert @batch.queued?
    
    @batch.state = nil
    assert !@batch.queued?
  end
  
  test "state is marked in progress" do
    @batch.state = "InProgress"
    assert @batch.in_progress?
    
    @batch.state = nil
    assert !@batch.in_progress?
  end
  
  test "state is marked completed" do
    @batch.state = "Completed"
    assert @batch.completed?
    
    @batch.state = nil
    assert !@batch.completed?
  end
  
  test "state is marked failed" do
    @batch.state = "Failed"
    assert @batch.failed?
    
    @batch.state = nil
    assert !@batch.failed?
  end
  
  test "should add a batch to a job and return a successful response" do
    bypass_authentication(@client)
    
    headers = {"Content-Type" => "text/csv; charset=UTF-8", 'X-Sfdc-Session' => '123456789'}
    request = fixture("batch_create_request.csv")
    response = fixture("batch_create_response.xml")
    jobId = "750E00000004N7uIAE"
    data = [
      {:Id__c => '12345', :Title__c => "This is a test video"}
    ]
    
    stub_request(:post, "#{api_url(@client)}job/#{jobId}/batch")
      .with(:body => request, :headers => headers)
      .to_return(:body => response, :status => 200)
    
    batch = @client.add_batch(jobId, data)
    
    assert_requested :post, "#{api_url(@client)}job/#{jobId}/batch", :body => request, :headers => headers, :times => 1
    
    assert_equal batch.jobId, jobId
    assert_equal batch.state, 'Queued'
  end
  
  test "should retrieve info for all batches in a job in a single request" do
    
  end
  
  test "should retrieve batch info" do
    bypass_authentication(@client)
    
    headers = {"Content-Type" => "text/csv; charset=UTF-8", 'X-Sfdc-Session' => '123456789'}
    response = fixture("batch_info_response.xml")
    jobId = "750E00000004N97IAE"
    batchId = "751E00000004ZRbIAM"
    
    stub_request(:get, "#{api_url(@client)}job/#{jobId}/batch/#{batchId}")
      .with(:headers => headers)
      .to_return(:body => response, :status => 200)
    
    batch = @client.batch_info(jobId, batchId)
    
    assert_requested :get, "#{api_url(@client)}job/#{jobId}/batch/#{batchId}", :headers => headers, :times => 1
    
    assert_equal batch.jobId, jobId
    assert_equal batch.state, 'Completed'
  end
  
end