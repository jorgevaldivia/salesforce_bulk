module SalesforceBulk
  class Job
    
    attr_reader :concurrency_mode
    attr_reader :external_id_field_name
    attr_accessor :id
    attr_reader :operation
    attr_reader :sobject
    attr_accessor :state
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
    
    def initialize(attrs={})
      @operation = attrs['operation']
      @external_id_field_name = attrs['external_id_field_name']
      @concurrency_mode = attrs['concurrency_mode']
      @sobject = attrs['sobject']
      @id = attrs['id']
    end
    
  end
end
