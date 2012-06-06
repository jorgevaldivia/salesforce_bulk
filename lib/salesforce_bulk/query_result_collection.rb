module SalesforceBulk
  class QueryResultCollection < Array
    
    attr_reader :client
    attr_reader :batch_id
    attr_reader :job_id
    attr_reader :total_size
    attr_reader :result_id
    attr_reader :previous_result_id
    attr_reader :next_result_id
    
    def initialize(client, job_id, batch_id, total_size=0, result_id=nil, previous_result_id=nil, next_result_id=nil)
      @client = client
      @job_id = job_id
      @batch_id = batch_id
      @total_size = total_size
      @result_id = result_id
      @previous_result_id = previous_result_id
      @next_result_id = next_result_id
    end
    
    def next?
      @next_result_id.present?
    end
    
    def next
      # if calls method on client to fetch data and returns new collection instance
      SalesforceBulk::QueryResultCollection.new(self.client, self.job_id, self.batch_id)
    end
    
    def previous?
      @previous_result_id.present?
    end
    
    def previous
      # if has previous, calls method on client to fetch data and returns new collection instance
      SalesforceBulk::QueryResultCollection.new(self.client, self.job_id, self.batch_id)
    end
    
  end
end