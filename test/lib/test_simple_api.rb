require 'test_helper'

class TestSimpleApi < Test::Unit::TestCase
  
  def setup
    options = {
      :username => 'myusername', 
      :password => 'mypassword',
      :token => "somelongtoken"
    }
    
    @client = SalesforceBulk::Client.new(options)
  end
  
  test "upsert" do
    @client.expects(:add_job).once.returns(SalesforceBulk::Job.new
    @client.expects(:add_batch).once.returns(SalesforceBulk::Batch.new)
    @client.expects(:close_job).once.returns(SalesforceBulk::Job.new
    @client.expects(:batch_info).at_least_once.returns(SalesforceBulk::Batch.new)
    @client.expects(:batch_result_list).once
    
    @client.upsert(:VideoEvent__c, :Id__c, [{:Id__c => '123'}])
  end
  
end