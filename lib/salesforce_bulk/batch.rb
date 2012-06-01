module SalesforceBulk
  class Batch
    
    attr_reader :client
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
    
    def initialize(client)
      @client = client
    end
    
    def create(job)
      if data.is_a? String
        # query
      else
        # all other operations
        #keys = data.reduce({}) {|h,pairs| puts 'reduce'; pairs.each {|k,v| puts 'pairs.each'; (h[k] ||= []) << v}; h}.keys
        keys = data.first.keys
        output_csv = keys.to_csv
        
        #puts "", keys.inspect,"",""
        
        data.each do |item|
          item_values = keys.map { |key| item[key] }
          output_csv += item_values.to_csv
        end
        
        headers = {"Content-Type" => "text/csv; charset=UTF-8"}
        
        #puts "","",output_csv,"",""
        
        response = @client.http_post("job/#{job.id}123/batch/", output_csv, headers)
        
        puts "","",response,"",""
        
        raise SalesforceError.new(response) unless response.is_a?(Net::HTTPSuccess)
        
        result = XmlSimple.xml_in(response.body, 'ForceArray' => false)
        
        puts "","",result,"",""
        
        @id = result["id"]
        @state = result["state"]
      end
    end
  end
end