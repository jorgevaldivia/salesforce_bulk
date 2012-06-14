module SalesforceBulk
  class Job
    
    attr_reader :concurrency_mode
    attr_reader :external_id_field_name
    attr_accessor :id
    attr_reader :operation
    attr_reader :sobject
    attr_accessor :job_id
    attr_accessor :state
    attr_accessor :created_by
    attr_accessor :created_at
    attr_accessor :updated_at
    attr_accessor :content_type
    attr_accessor :queued_batches
    attr_accessor :in_progress_batches
    attr_accessor :completed_batches
    attr_accessor :failed_batches
    attr_accessor :total_batches
    attr_accessor :processed_batches
    attr_accessor :retries
    attr_accessor :api_version
    attr_accessor :failed_records
    attr_accessor :apex_processing_time
    attr_accessor :api_active_processing_time
    attr_accessor :total_processing_time
#  <id>750E00000004N1mIAE</id>
#  <operation>upsert</operation>
#  <object>VideoEvent__c</object>
#  <createdById>005E00000017spfIAA</createdById>
#  <createdDate>2012-05-30T04:08:30.000Z</createdDate>
#  <systemModstamp>2012-05-30T04:08:30.000Z</systemModstamp>
#  <state>Open</state>
#  <externalIdFieldName>Id__c</externalIdFieldName>
#  <concurrencyMode>Parallel</concurrencyMode>
#  <contentType>CSV</contentType>
#  <numberBatchesQueued>0</numberBatchesQueued>
#  <numberBatchesInProgress>0</numberBatchesInProgress>
#  <numberBatchesCompleted>0</numberBatchesCompleted>
#  <numberBatchesFailed>0</numberBatchesFailed>
#  <numberBatchesTotal>0</numberBatchesTotal>
#  <numberRecordsProcessed>0</numberRecordsProcessed>
#  <numberRetries>0</numberRetries>
#  <apiVersion>24.0</apiVersion>
#  <numberRecordsFailed>0</numberRecordsFailed>
#  <totalProcessingTime>0</totalProcessingTime>
#  <apiActiveProcessingTime>0</apiActiveProcessingTime>
#  <apexProcessingTime>0</apexProcessingTime>
    
    def self.new_from_xml(data)
      job = data['id']
      job.job_id = data['jobId']
      job.operation = data['operation']
      job.created_by = data['createdById']
      job.state = data['state']
      job.started_at = DateTime.parse(data['createdDate'])
      job.ended_at = DateTime.parse(data['systemModstamp'])
      job.external_id_field_name = data['externalIdFieldName']
      job.concurrency_mode = data['concurrencyMode']
      job.content_type = data['contentType']
      job.queued_batches = data['numberBatchesQueued'].to_i
      job.in_progress_batches = data['numberBatchesInProgress'].to_i
      job.completed_batches = data['numberBatchesCompleted'].to_i
      job.failed_batches = data['numberBatchesFailed'].to_i
      job.processed_records = data['numberRecordsProcessed'].to_i
      job.retries = data['retries'].to_i
      job.failed_records = data['numberRecordsFailed'].to_i
      job.total_processing_time = data['totalProcessingTime'].to_i
      job.api_active_processing_time = data['apiActiveProcessingTime'].to_i
      job.apex_processing_time = data['apex_processing_time'].to_i
      job
    end
    
    def initialize(attrs={})
      @operation = attrs['operation']
      @external_id_field_name = attrs['external_id_field_name']
      @concurrency_mode = attrs['concurrency_mode']
      @sobject = attrs['sobject']
      @id = attrs['id']
    end
    
  end
end
