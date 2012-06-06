module SalesforceBulk
  class BatchResultCollection < Array
    
    attr_reader :batch_id
    attr_reader :job_id
    
    def initialize(job_id, batch_id)
      @job_id = job_id
      @batch_id = batch_id
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