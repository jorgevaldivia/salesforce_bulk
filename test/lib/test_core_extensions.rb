require 'test_helper'

class TestCoreExtensions < Test::Unit::TestCase
  
  test "to_b" do
    assert_equal "true".to_b, true
    assert_equal "TRUE".to_b, true
    assert_equal "false".to_b, false
    assert_equal "FALSE".to_b, false
    assert_equal "  true  ".to_b, true
    assert_equal "  false  ".to_b, false
  end
  
  # Taken from ActiveSupport: /activesupport/test/core_ext/blank_test.rb
  
  BLANK = [ nil, false, '', '   ', "  \n\t  \r ", [], {} ]
  NOT   = [ Object.new, true, 0, 1, 'a', [nil], { nil => 0 } ]
  
  test "blank?" do
    BLANK.each { |v| assert v.blank?,  "#{v.inspect} should be blank" }
    NOT.each   { |v| assert !v.blank?, "#{v.inspect} should not be blank" }
  end
  
  test "present?" do
    BLANK.each { |v| assert !v.present?, "#{v.inspect} should not be present" }
    NOT.each   { |v| assert v.present?,  "#{v.inspect} should be present" }
  end
  
end