module SalesforceBulk
  class QueryResultCollection < Array
    
    attr_reader :client
    attr_reader :batchId
    attr_reader :jobId
    attr_reader :totalSize
    attr_reader :resultId
    attr_reader :previousResultId
    attr_reader :nextResultId
    
    def initialize(client, jobId, batchId, totalSize=0, resultId=nil, previousResultId=nil, nextResultId=nil)
      @client = client
      @jobId = jobId
      @batchId = batchId
      @totalSize = totalSize
      @resultId = resultId
      @previousResultId = previousResultId
      @nextResultId = nextResultId
    end
    
    def next?
      @nextResultId.present?
    end
    
    def next
      # if calls method on client to fetch data and returns new collection instance
      SalesforceBulk::QueryResultCollection.new(self.client, self.jobId, self.batchId)
    end
    
    def previous?
      @previousResultId.present?
    end
    
    def previous
      # if has previous, calls method on client to fetch data and returns new collection instance
      SalesforceBulk::QueryResultCollection.new(self.client, self.jobId, self.batchId)
    end
    
  end
end