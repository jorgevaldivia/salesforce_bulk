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
        elsif @operation == :query
          @concurrency_mode = options[:concurrency_mode] || :Parallel
        end
        
        @sobject = options[:sobject]
      else
        @id = options[:id]
      end
    end
    
    
    def get_batch_result()
      path = "job/#{@@job_id}/batch/#{@@batch_id}/result"
      headers = Hash["Content-Type" => "text/xml; charset=UTF-8"]

      response = @@connection.get_request(nil, path, headers)

#
# FIXME ? 
# ENHANCE ?
# Loop through all results and collect each. All results are not returned in a single response.
# https://github.com/WWJacob/salesforce_bulk/commit/8f9e68c390230e885823e45cd2616ac3159697ef
#
      if(@@operation == "query") # The query op requires us to do another request to get the results
        response_parsed = XmlSimple.xml_in(response)
        result_id = response_parsed["result"][0]

        path = "job/#{@@job_id}/batch/#{@@batch_id}/result/#{result_id}"
        headers = Hash.new
        headers = Hash["Content-Type" => "text/xml; charset=UTF-8"]
        #puts "path is: #{path}\n"
        
        response = @@connection.get_request(nil, path, headers)
        #puts "\n\nres2: #{response.inspect}\n\n"
      end

#
# FIXME ?
# https://github.com/WWJacob/salesforce_bulk/commit/6a9527a5dca6e2eb74e192e9476f614b59726d3d
#
      response = response.lines.to_a[1..-1].join
      csvRows = CSV.parse(response)

#
# TODO
# Implement addition
# https://github.com/nswarr/salesforce_bulk/commit/217fe0bba27b953f515af88467ed8984871aebf4#diff-2
#
      CSV.parse(response).map do |row|
        {
          :id => row[0],
          :success => row[1],
          :created => row[2],
          :error_message => row[3]
        }
      end
    end

  end
end
