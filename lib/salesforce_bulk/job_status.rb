module SalesforceBulk
  JobStatus = Struct.new(:id,
    :job_id,
    :status,
    :status_message,
    :created_at,
    :records_processed,
    :records_failed,
    :total_processing_time,
    :api_active_processing_time,
    :apex_processing_time) do

    MAPPING = {
      id: ['id'],
      job_id: ['jobId'],
      status: ['state'],
      status_message: ['stateMessage'],
      created_at: ['createdDate', lambda{|v| DateTime.parse(v)}],
      records_processed: ['numberRecordsProcessed', lambda{|v| v.to_i}],
      records_failed: ['numberRecordsFailed', lambda{|v| v.to_i}],
      total_processing_time: ['totalProcessingTime', lambda{|v| v.to_i}],
      api_active_processing_time: ['apiActiveProcessingTime', lambda{|v| v.to_i}],
      apex_processing_time: ['apexProcessingTime', lambda{|v| v.to_i}],
    }

    def self.parse response
      response_parsed = XmlSimple.xml_in(response)
      MAPPING.each_with_object(JobStatus.new) do | (k,v), js |
        js.send(:"#{k}=", extract_value(response_parsed, v))
      end
    end

    private
    def self.extract_value xml, lookup_arrray
      key = lookup_arrray[0]
      value = xml[key][0] rescue nil
      lookup_arrray.size > 1 ? lookup_arrray[1].call(value) : value.strip rescue nil
    end
  end
end