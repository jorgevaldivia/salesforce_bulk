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
      is_state 'inprogress'
    end
    
    def queued?
      is_state 'queued'
    end
    
    def completed?
      is_state 'completed'
    end
    
    def failed?
      is_state 'failed'
    end
    
    private
      
      def is_state(value)
        !self.state.nil? && self.state.casecmp(value) == 0
      end
      
  end
end