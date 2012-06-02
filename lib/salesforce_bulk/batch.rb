module SalesforceBulk
  class Batch
    
    attr_accessor :data
    attr_accessor :id
    attr_accessor :jobId
    attr_accessor :state
    
# <id>751D0000000004rIAA</id>
# <jobId>750D0000000002lIAA</jobId>
# <state>InProgress</state>
# <createdDate>2009-04-14T18:15:59.000Z</createdDate>
# <systemModstamp>2009-04-14T18:15:59.000Z</systemModstamp>
# <numberRecordsProcessed>0</numberRecordsProcessed>
    
    def initialize
      
    end
    
    def in_progress?
      state? 'InProgress'
    end
    
    def queued?
      state? 'Queued'
    end
    
    def completed?
      state? 'Completed'
    end
    
    def failed?
      state? 'Failed'
    end
    
    def state?(value)
      !self.state.nil? && self.state.casecmp(value) == 0
    end
  end
end