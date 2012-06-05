require 'test_helper'

class TestQueryResultCollection < Test::Unit::TestCase
  
  def setup
    options = {
      :username => 'myusername', 
      :password => 'mypassword',
      :token => "somelongtoken"
    }
    
    @client = SalesforceBulk::Client.new(options)
    @jobId = "123"
    @batchId = "234"
    @resultIds = ["12","23","34"]
  end
  
  test "initilize" do
    collection = SalesforceBulk::QueryResultCollection.new(@client, @jobId, @batchId)
    assert_equal collection.client, @client
    assert_equal collection.jobId, @jobId
    assert_equal collection.batchId, @batchId
    assert_equal collection.currentIndex, 0
    
    collection = SalesforceBulk::QueryResultCollection.new(@client, @jobId, @batchId, 5)
    assert_equal collection.currentIndex, 5
  end
  
  test "next?" do
    collection = SalesforceBulk::QueryResultCollection.new(@client, @jobId, @batchId)
    collection.push *@resultIds
    assert collection.next?
    
    collection.instance_variable_set("@currentIndex", 2)
    assert !collection.next?
  end
  
  test "previous?" do
    collection = SalesforceBulk::QueryResultCollection.new(@client, @jobId, @batchId)
    collection.push *@resultIds
    assert !collection.previous?
    
    collection.instance_variable_set("@currentIndex", 2)
    assert collection.previous?
  end
  
end