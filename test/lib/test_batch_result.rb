require 'test_helper'

class TestBatchResult < Test::Unit::TestCase
  
  def setup
    @result_created = SalesforceBulk::BatchResult.new('123', true, true, '')
    @result_updated = SalesforceBulk::BatchResult.new('123', true, false, '')
    @result_failed = SalesforceBulk::BatchResult.new('123', false, false, 'Some Error Message This Is')
  end
  
  test "basic initialization" do
    assert_equal @result_created.id, '123'
    assert_equal @result_created.success, true
    assert_equal @result_created.successful?, true
    assert_equal @result_created.created, true
    assert_equal @result_created.created?, true
    assert_equal @result_created.error, ''
    assert_equal @result_created.error?, false
    assert_equal @result_created.updated?, false
  end
  
  test "initialization from CSV row" do
    #@br = SalesforceBulk::BatchResult.new_from_csv()
  end
  
  test "error?" do
    assert @result_failed.error?
    
    assert !@result_created.error?
    assert !@result_updated.error?
  end
  
  test "updated?" do
    assert @result_updated.updated?
    
    assert !@result_created.updated?
    assert !@result_failed.updated?
  end
  
end