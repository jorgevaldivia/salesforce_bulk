module SalesforceBulk
  class Job
    
    attr_reader :concurrency_mode
    attr_reader :external_id_field_name
    attr_accessor :id
    attr_reader :operation
    attr_reader :sobject
    attr_accessor :state
    
    def initialize(client, options={})
      @client = client
      @operation = options[:operation]
      
      if !@operation.nil?
        if @operation == :upsert
          @external_id_field_name = options[:external_id_field_name]
        end
        
        @concurrency_mode = options[:concurrency_mode]
        @sobject = options[:sobject]
      else
        @id = options[:id]
      end
    end
    
  end
end
