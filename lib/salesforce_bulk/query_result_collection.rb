module SalesforceBulk
  class QueryResultCollection < Array
    
    attr_reader :client
    attr_reader :batch_id
    attr_reader :job_id
    attr_reader :result_id
    attr_reader :result_ids
    
    def initialize(client, job_id, batch_id, result_id=nil, result_ids=[])
      @client = client
      @job_id = job_id
      @batch_id = batch_id
      @result_id = result_id
      @result_ids = result_ids
      @current_index = result_ids.index(result_id) || 0
    end
    
    def next?
      @result_ids.present? && @current_index < @result_ids.length - 1
    end
    
    def next
      @client.query_result(job_id, batch_id, result_ids[@current_index + 1], result_ids) if next?
    end
    
    def previous?
      @result_ids.present? && @current_index > 0
    end
    
    def previous
      @client.query_result(job_id, batch_id, result_ids[@current_index - 1], result_ids) if previous?
    end
    
  end
end