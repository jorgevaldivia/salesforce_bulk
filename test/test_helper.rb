require 'test/unit'
require 'shoulda'
require 'salesforce_bulk'

class Test::Unit::TestCase
  
  def self.test(name, &block)
    define_method("test #{name.inspect}", &block)
  end
  
end