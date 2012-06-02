module SalesforceBulk
  class BatchResultCollection < Array
    
    attr_reader :batchId
    attr_reader :jobId
    
    def initialize(jobId, batchId)
      @jobId = jobId
      @batchId = batchId
    end
    
    def any_failures?
      self.any? { |result| result.error.length > 0 }
    end
    
    def failed
      self.select { |result| result.error.length > 0 }
    end
    
    def completed
      self.select { |result| result.success }
    end
    
    def created
      self.select { |result| result.success && result.created }
    end
    
  end
end