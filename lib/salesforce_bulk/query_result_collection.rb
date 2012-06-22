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
      if next?
        replace(@client.query_result(job_id, batch_id, result_ids[@current_index + 1]))
        @current_index += 1
        @result_id = @result_ids[@current_index]
      end
      
      self
    end
    
    def previous?
      @result_ids.present? && @current_index > 0
    end
    
    def previous
      if previous?
        replace(@client.query_result(job_id, batch_id, result_ids[@current_index - 1]))
        @current_index -= 1
        @result_id = @result_ids[@current_index]
      end
      
      self
    end
    
  end
end