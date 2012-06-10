require 'test_helper'

class TestCoreExtensions < Test::Unit::TestCase
  
  test "to_b" do
    assert_equal "true".to_b, true
    assert_equal "TRUE".to_b, true
    assert_equal "false".to_b, false
    assert_equal "FALSE".to_b, false
    assert_equal "  true  ".to_b, true
    assert_equal "  false  ".to_b, false
    assert_equal "Any true value".to_b, "Any true value"
  end
  
end