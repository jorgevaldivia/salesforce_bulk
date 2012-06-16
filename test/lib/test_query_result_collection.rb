require 'test_helper'

class TestQueryResultCollection < Test::Unit::TestCase
  
  def setup
    options = {
      :username => 'myusername', 
      :password => 'mypassword',
      :token => "somelongtoken"
    }
    
    @client = SalesforceBulk::Client.new(options)
    @job_id = "123"
    @batch_id = "234"
    @result_ids = ["12","23","34"]
    @result_id = @result_ids[1]
    @collection = SalesforceBulk::QueryResultCollection.new(@client, @job_id, @batch_id, @result_id, @result_ids)
  end
  
  test "initilize using defaults" do
    collection = SalesforceBulk::QueryResultCollection.new(@client, @job_id, @batch_id)
    
    assert_equal collection.client, @client
    assert_equal collection.job_id, @job_id
    assert_equal collection.batch_id, @batch_id
    assert_nil collection.result_id
    assert_equal collection.result_ids, []
  end
  
  test "initilize with all values" do
    assert_equal @collection.client, @client
    assert_equal @collection.job_id, @job_id
    assert_equal @collection.batch_id, @batch_id
    assert_equal @collection.result_id, @result_id
    assert_equal @collection.result_ids, @result_ids
  end
  
  test "next?" do
    assert @collection.next?
    
    @collection.instance_variable_set('@current_index', @result_ids.length)
    assert !@collection.next?
    
    @collection.instance_variable_set('@result_ids', nil)
    assert !@collection.next?
  end
  
  test "next" do
    assert_kind_of SalesforceBulk::QueryResultCollection, @collection.next
  end
  
  test "previous?" do
    assert @collection.previous?
    
    @collection.instance_variable_set('@current_index', 0)
    assert !@collection.previous?
    
    @collection.instance_variable_set('@result_ids', nil)
    assert !@collection.previous?
  end
  
  test "previous" do
    assert_kind_of SalesforceBulk::QueryResultCollection, @collection.previous
  end
  
end