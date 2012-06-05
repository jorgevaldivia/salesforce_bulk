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
    @resultId = @resultIds[1]
    @previousResultId = @resultIds.first
    @nextResultId = @resultIds.last
  end
  
  test "initilize using defaults" do
    collection = SalesforceBulk::QueryResultCollection.new(@client, @jobId, @batchId)
    assert_equal collection.client, @client
    assert_equal collection.jobId, @jobId
    assert_equal collection.batchId, @batchId
    assert_equal collection.resultId, nil
    assert_equal collection.previousResultId, nil
    assert_equal collection.nextResultId, nil
  end
  
  test "initilize with all values" do
    collection = SalesforceBulk::QueryResultCollection.new(@client, @jobId, @batchId, @resultId, @previousResultId, @nextResultId)
    assert_equal collection.client, @client
    assert_equal collection.jobId, @jobId
    assert_equal collection.batchId, @batchId
    assert_equal collection.resultId, @resultId
    assert_equal collection.previousResultId, @previousResultId
    assert_equal collection.nextResultId, @nextResultId
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