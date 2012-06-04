class String
  # From ActiveSupport gem: /activesupport/lib/active_support/core_ext/string/encoding.rb
  if defined?(Encoding) && "".respond_to?(:encode)
    def encoding_aware?
      true
    end
  else
    def encoding_aware?
      false
    end
  end
  
  # For converting "true" and "false" string values returned 
  # by Salesforce Bulk API in batch results to real booleans.
  def to_b
    present? && lstrip.rstrip.casecmp("true") == 0
  end
end