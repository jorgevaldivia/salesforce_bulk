module SalesforceBulk
  class QueryResultCollection < Array
    
    attr_reader :client
    attr_reader :currentIndex
    attr_reader :batchId
    attr_reader :jobId
    attr_reader :resultIds
    
    def initialize(client, jobId, batchId, currentIndex=0)
      @client = client
      @jobId = jobId
      @batchId = batchId
      @currentIndex = currentIndex
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