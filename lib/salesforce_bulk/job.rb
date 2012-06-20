module SalesforceBulk
  class Job
    
    attr_accessor :concurrency_mode
    attr_accessor :external_id_field_name
    attr_accessor :id
    attr_accessor :operation
    attr_accessor :sobject
    attr_accessor :state
    attr_accessor :created_by
    attr_accessor :created_at
    attr_accessor :completed_at
    attr_accessor :content_type
    attr_accessor :queued_batches
    attr_accessor :in_progress_batches
    attr_accessor :completed_batches
    attr_accessor :failed_batches
    attr_accessor :total_batches
    attr_accessor :retries
    attr_accessor :failed_records
    attr_accessor :processed_records
    attr_accessor :apex_processing_time
    attr_accessor :api_active_processing_time
    attr_accessor :total_processing_time
    attr_accessor :api_version
    
    def self.new_from_xml(data)
      job = self.new
      job.id = data['id']
      job.operation = data['operation']
      job.sobject = data['object']
      job.created_by = data['createdById']
      job.state = data['state']
      job.created_at = DateTime.parse(data['createdDate'])
      job.completed_at = DateTime.parse(data['systemModstamp'])
      job.external_id_field_name = data['externalIdFieldName']
      job.concurrency_mode = data['concurrencyMode']
      job.content_type = data['contentType']
      job.queued_batches = data['numberBatchesQueued'].to_i
      job.in_progress_batches = data['numberBatchesInProgress'].to_i
      job.completed_batches = data['numberBatchesCompleted'].to_i
      job.failed_batches = data['numberBatchesFailed'].to_i
      job.total_batches = data['totalBatches'].to_i
      job.retries = data['retries'].to_i
      job.processed_records = data['numberRecordsProcessed'].to_i
      job.failed_records = data['numberRecordsFailed'].to_i
      job.total_processing_time = data['totalProcessingTime'].to_i
      job.api_active_processing_time = data['apiActiveProcessingTime'].to_i
      job.apex_processing_time = data['apexProcessingTime'].to_i
      job.api_version = data['apiVersion'].to_i
      job
    end
    
    def aborted?
      state? 'Aborted'
    end
    
    def closed?
      state? 'Closed'
    end
    
    def open?
      state? 'Open'
    end
    
    def state?(value)
      self.state.present? && self.state.casecmp(value) == 0
    end
  end
end
