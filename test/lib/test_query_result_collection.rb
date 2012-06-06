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
    @collection = SalesforceBulk::QueryResultCollection.new(@client, @jobId, @batchId, @resultId, @previousResultId, @nextResultId)
  end
  
  test "initilize using defaults" do
    collection = SalesforceBulk::QueryResultCollection.new(@client, @jobId, @batchId)
    assert_equal collection.client, @client
    assert_equal collection.jobId, @jobId
    assert_equal collection.batchId, @batchId
    assert_nil collection.resultId
    assert_nil collection.previousResultId
    assert_nil collection.nextResultId
  end
  
  test "initilize with all values" do
    assert_equal @collection.client, @client
    assert_equal @collection.jobId, @jobId
    assert_equal @collection.batchId, @batchId
    assert_equal @collection.resultId, @resultId
    assert_equal @collection.previousResultId, @previousResultId
    assert_equal @collection.nextResultId, @nextResultId
  end
  
  test "next?" do
    assert @collection.next?
    
    @collection.instance_variable_set('@nextResultId', '')
    assert !@collection.next?
  end
  
  test "next" do
    assert_kind_of SalesforceBulk::QueryResultCollection, @collection.next
  end
  
  test "previous?" do
    assert @collection.previous?
    
    @collection.instance_variable_set('@previousResultId', '')
    assert !@collection.previous?
  end
  
  test "previous" do
    assert_kind_of SalesforceBulk::QueryResultCollection, @collection.previous
  end
  
end