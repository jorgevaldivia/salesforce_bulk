require 'spec_helper'

describe SalesforceBulk::JobStatus do
  let(:field_not_found_response) do
    %Q{
      <?xml version="1.0" encoding="UTF-8"?>
        <batchInfo xmlns="http://www.force.com/2009/06/asyncapi/dataload">
          <id>751M0000000A0htIAC</id>
          <jobId>750M00000008yJsIAI</jobId>
          <state>Failed</state>
          <stateMessage>
            InvalidBatch : Field name not found : An_Awesome_Field__c
          </stateMessage>
          <createdDate>2013-04-08T16:15:24.000Z</createdDate>
          <systemModstamp>2013-04-08T16:15:24.000Z</systemModstamp>
          <numberRecordsProcessed>0</numberRecordsProcessed>
          <numberRecordsFailed>0</numberRecordsFailed>
          <totalProcessingTime>0</totalProcessingTime>
          <apiActiveProcessingTime>0</apiActiveProcessingTime>
          <apexProcessingTime>0</apexProcessingTime>
        </batchInfo>
    }
  end

  describe '.parse_response' do
    it 'should create JobStatus correctly for failed response' do
      js = SalesforceBulk::JobStatus.new
      js.id = '751M0000000A0htIAC'
      js.job_id = '750M00000008yJsIAI'
      js.name = 'Failed'
      js.message = 'InvalidBatch : Field name not found : An_Awesome_Field__c'
      js.created_at = DateTime.parse '2013-04-08T16:15:24.000Z'
      js.records_processed = 0
      js.records_failed = 0
      js.total_processing_time = 0
      js.api_active_processing_time = 0
      js.apex_processing_time = 0

      expect(SalesforceBulk::JobStatus.parse(field_not_found_response)).to eq(js)
    end
  end
end