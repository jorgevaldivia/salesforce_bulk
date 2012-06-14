module SalesforceBulk
  class Batch
    
    attr_accessor :apex_processing_time
    attr_accessor :api_active_processing_time
    attr_accessor :ended_at    
    attr_accessor :failed_records
    attr_accessor :id
    attr_accessor :job_id
    attr_accessor :processed_records
    attr_accessor :started_at
    attr_accessor :state
    attr_accessor :total_processing_time
    
    def self.new_from_xml(data)
      batch = self.new
      batch.id = data['id']
      batch.job_id = data['jobId']
      batch.state = data['state']
      batch.started_at = data['createdDate']
      batch.ended_at = data['systemModstamp']
      batch.processed_records = data['numberRecordsProcessed'].to_i
      batch.failed_records = data['numberRecordsFailed'].to_i
      batch.total_processing_time = data['totalProcessingTime'].to_i
      batch.api_active_processing_time = data['apiActiveProcessingTime'].to_i
      batch.apex_processing_time = data['apex_processing_time'].to_i
      batch
    end
    
    def initialize
      
    end
    
    def in_progress?
      state? 'InProgress'
    end
    
    def queued?
      state? 'Queued'
    end
    
    def completed?
      state? 'Completed'
    end
    
    def failed?
      state? 'Failed'
    end
    
    def state?(value)
      self.state.present? && self.state.casecmp(value) == 0
    end
  end
end