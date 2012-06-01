module SalesforceBulk
  class BatchResult
    
    # A boolean indicating if record was created. If updated value is false.
    attr_reader :created
    
    # The error message.
    attr_reader :error
    
    # The record's unique id.
    attr_reader :id
    
    # If record was created successfully. If false then an error message is provided. 
    attr_reader :success
    
    def initialize(attrs={})
      
    end
  end
end