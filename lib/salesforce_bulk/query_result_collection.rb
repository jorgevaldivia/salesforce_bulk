module SalesforceBulk
  class QueryResultCollection < Array
    
    attr_reader :client
    attr_reader :currentIndex
    attr_reader :batchId
    attr_reader :jobId
    attr_reader :resultIds
    
    def initialize(client, jobId, batchId, resultIds) #previousResultId, nextResultId, currentResultId
      @client = client
      @jobId = jobId
      @batchId = batchId
      @resultIds = resultIds
      @currentIndex = resultIds.first
      
    end
    
    def next?
      
    end
    
    def next
      
    end
    
    def previous?
      
    end
    
    def previous
      
    end
    
  end
end