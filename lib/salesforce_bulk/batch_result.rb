module SalesforceBulk
  class BatchResult
    
    # A boolean indicating if record was created. If updated value is false.
    attr_accessor :created
    
    # The error message.
    attr_accessor :error
    
    # The record's unique id.
    attr_accessor :id
    
    # If record was created successfully. If false then an error message is provided. 
    attr_accessor :success
    
    def initialize(id, success, created, error)
      @id = id
      @success = success
      @created = created
      @error = error
    end
    
    def error?
      error.present?
    end
    
    def created?
      created
    end
    
    def successful?
      success
    end
    
    def updated?
      !created && success
    end
  end
end