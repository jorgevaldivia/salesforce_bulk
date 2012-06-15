require 'test_helper'

class TestSimpleApi < Test::Unit::TestCase
  
  def setup
    options = {
      :username => 'myusername', 
      :password => 'mypassword',
      :token => "somelongtoken"
    }
    
    @client = SalesforceBulk::Client.new(options)
    @job = SalesforceBulk::Job.new
    @job.id = "123"
    @batch = SalesforceBulk::Batch.new
    @batch.id = "456"
  end
  
  test "delete" do
    data = [{:Id => '123123'}, {:Id => '234234'}]
    
    @client.expects(:add_job).once.with(:delete, :VideoEvent__c).returns(@job)
    @client.expects(:add_batch).once.with(@job.id, data).returns(@batch)
    @client.expects(:close_job).once.with(@job.id).returns(@job)
    @client.expects(:batch_info).at_least_once.returns(@batch)
    @client.expects(:batch_result_list).once.with(@job.id, @batch.id)
    
    @client.delete(:VideoEvent__c, data)
  end
  
  test "insert" do
    data = [{:Title__c => 'Test Title'}, {:Title__c => 'Test Title'}]
    
    @client.expects(:add_job).once.with(:insert, :VideoEvent__c).returns(@job)
    @client.expects(:add_batch).once.with(@job.id, data).returns(@batch)
    @client.expects(:close_job).once.with(@job.id).returns(@job)
    @client.expects(:batch_info).at_least_once.returns(@batch)
    @client.expects(:batch_result_list).once.with(@job.id, @batch.id)
    
    @client.insert(:VideoEvent__c, data)
  end
  
  test "update" do
    data = [{:Id => '123123', :Title__c => 'Test Title'}, {:Id => '234234', :Title__c => 'A Second Title'}]
    
    @client.expects(:add_job).once.with(:update, :VideoEvent__c).returns(@job)
    @client.expects(:add_batch).once.with(@job.id, data).returns(@batch)
    @client.expects(:close_job).once.with(@job.id).returns(@job)
    @client.expects(:batch_info).at_least_once.returns(@batch)
    @client.expects(:batch_result_list).once.with(@job.id, @batch.id)
    
    @client.update(:VideoEvent__c, data)
  end
  
  test "upsert" do
    data = [{:Id__c => '123123', :Title__c => 'Test Title'}, {:Id__c => '234234', :Title__c => 'A Second Title'}]
    
    @client.expects(:add_job).once.with(:upsert, :VideoEvent__c, :concurrency_mode => nil, :external_id_field_name => :Id__c).returns(@job)
    @client.expects(:add_batch).once.with(@job.id, data).returns(@batch)
    @client.expects(:close_job).once.with(@job.id).returns(@job)
    @client.expects(:batch_info).at_least_once.returns(@batch)
    @client.expects(:batch_result_list).once.with(@job.id, @batch.id)
    
    @client.upsert(:VideoEvent__c, :Id__c, data)
  end
  
end