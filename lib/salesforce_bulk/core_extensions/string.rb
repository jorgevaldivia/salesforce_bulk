class String
  # For converting "true" and "false" string values returned 
  # by Salesforce Bulk API in batch results to real booleans.
  def to_b
    if present?
      if lstrip.rstrip.casecmp("true") == 0
        return true
      elsif lstrip.rstrip.casecmp("false") == 0
        return false
      end
    end
    self
  end
end