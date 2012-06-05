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
      @currentIndex < length - 1
    end
    
    def next
      # if has next, calls method on client to fetch data and returns new collection instance
    end
    
    def previous?
      @currentIndex > 0
    end
    
    def previous
      # if has previous, calls method on client to fetch data and returns new collection instance
    end
    
  end
end