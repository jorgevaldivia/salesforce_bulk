module SalesforceBulk
  # Interface for operating the Salesforce Bulk REST API
  class Client
    # If true, print API debugging information to stdout. Defaults to false.
    attr_accessor :debugging
    
    # The host to use for authentication. Defaults to login.salesforce.com.
    attr_accessor :host
    
    # The instance host to use for API calls. Determined from login response.
    attr_accessor :instance_host
    
    # The Salesforce password
    attr_accessor :password
    
    # The Salesforce security token
    attr_accessor :token
    
    # The Salesforce username
    attr_accessor :username
    
    # The API version the client is using. Defaults to 24.0.
    attr_accessor :version
    
    def initialize(options={})
      if options.is_a?(String)
        options = YAML.load_file(options)
        # FIXME: ActiveSupport gem provides a symbolize_keys method. We 
        # use other ActiveSupport methods that we copied over.. perhaps 
        # just best to include the gem now. Its clear we need it.
        options = options.inject({}){|memo,(k,v)| memo[k.to_sym] = v; memo}
      end
      
      self.username = options[:username]
      self.password = "#{options[:password]}#{options[:token]}"
      self.token = options[:token]
      
      options = {:debugging => false, :host => 'login.salesforce.com', :version => 24.0}.merge(options)
      
      self.debugging = options[:debugging]
      self.host = options[:host]
      self.version = options[:version]
      
      @api_path_prefix = "/services/async/#{self.version}/"
    end
    
    def authenticate
      xml = '<?xml version="1.0" encoding="utf-8"?>'
      xml += '<env:Envelope xmlns:xsd="http://www.w3.org/2001/XMLSchema"'
      xml += ' xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"'
      xml += ' xmlns:env="http://schemas.xmlsoap.org/soap/envelope/">'
      xml += "<env:Body>"
      xml += '<n1:login xmlns:n1="urn:partner.soap.sforce.com">'
      xml += "<n1:username>#{self.username}</n1:username>"
      xml += "<n1:password>#{self.password}</n1:password>"
      xml += "</n1:login>"
      xml += "</env:Body>"
      xml += "</env:Envelope>"
      
      headers = {'Content-Type' => 'text/xml', 'SOAPAction' => 'login'}
      
      response = http_post("/services/Soap/u/#{self.version}", xml, headers)
      
      data = XmlSimple.xml_in(response.body)
      
      @session_id = data['Body'][0]['loginResponse'][0]['result'][0]['sessionId'][0]
      
      url = data['Body'][0]['loginResponse'][0]['result'][0]['serverUrl'][0]
      
      self.instance_host = "#{instance_id(url)}.salesforce.com"
    end
    
    def abort_job(jobId)
      xml = '<?xml version="1.0" encoding="utf-8"?>'
      xml += '<jobInfo xmlns="http://www.force.com/2009/06/asyncapi/dataload">'
      xml += "<state>Aborted</state>"
      xml += "</jobInfo>"
      
      #puts "","",xml
      response = http_post("job/#{jobId}", xml)
      data = XmlSimple.xml_in(response.body, :ForceArray => false)
      #puts "","",response
      
      job = Job.new
      job.id = data['id']
      job.state = data['state']
      job
    end
    
    def add_batch(jobId, data)
      # Despite the content for a query operation batch being plain text we 
      # still have to specify CSV content type per API docs.
      headers = {"Content-Type" => "text/csv; charset=UTF-8"}
      
      if data.is_a? String # query
        response = http_post("job/#{jobId}/batch", data, headers)
      else # all other operations
        keys = data.first.keys
        output_csv = keys.to_csv
        
        data.each do |item|
          item_values = keys.map { |key| item[key] }
          output_csv += item_values.to_csv
        end
        
        #puts "", keys.inspect,"",""
        #puts "","",output_csv,"",""
        
        response = http_post("job/#{jobId}/batch", output_csv, headers)
        #puts "","",response,"",""
      end
      
      result = XmlSimple.xml_in(response.body, 'ForceArray' => false)
      #puts "","",result,"",""
      
      batch = Batch.new
      batch.id = result['id']
      batch.job_id = result['jobId']
      batch.state = result['state']
      batch
    end
    
    def add_job(options={})
      job = Job.new(options)
      
      xml = '<?xml version="1.0" encoding="utf-8"?>'
      xml += '<jobInfo xmlns="http://www.force.com/2009/06/asyncapi/dataload">'
      xml += "<operation>#{job.operation}</operation>"
      xml += "<object>#{job.sobject}</object>"
      xml += "<externalIdFieldName>#{job.external_id_field_name}</externalIdFieldName>" if job.external_id_field_name
      xml += "<concurrencyMode>#{job.concurrency_mode}</concurrencyMode>" if job.concurrency_mode
      xml += "<contentType>CSV</contentType>"
      xml += "</jobInfo>"
      
      #puts "", xml, ""
      response = http_post("job", xml)
      data = XmlSimple.xml_in(response.body, :ForceArray => false)
      #puts "", response
      
      job.id = data['id']
      job.state = data['state']
      job
    end
    
    def batch_info_list(jobId)
      response = http_get("job/#{jobId}/batch")
      #puts "","",response,"",""
      result = XmlSimple.xml_in(response.body, 'ForceArray' => false)
      #puts "","",result,"",""
      
      result['batchInfo'].collect do |info|
        batch = Batch.new
        batch.id = info['id']
        batch.job_id = info['jobId']
        batch.state = info['state']
        batch
      end
    end
    
    def batch_info(jobId, batchId)
      headers = {"Content-Type" => "text/csv; charset=UTF-8"}
      response = http_get("job/#{jobId}/batch/#{batchId}", headers)
      #puts "","",response,"",""
      result = XmlSimple.xml_in(response.body, 'ForceArray' => false)
      #puts "","",result,"",""
      
      batch = Batch.new
      batch.id = result['id']
      batch.job_id = result['jobId']
      batch.state = result['state']
      batch
    end
    
    def batch_result_list(jobId, batchId)
      response = http_get("job/#{jobId}/batch/#{batchId}/result")
      
      if response.body =~ /<.*?>/m
        result = XmlSimple.xml_in(response.body)
        
        if result['result'].present?
          col = QueryResultCollection.new(self, jobId, batchId, 0, result['result'].first, result['result'])
          
          result = query_result(jobId, batchId, result['result'].first, result['result'])
        end
      else
        result = BatchResultCollection.new(jobId, batchId)
        
        CSV.parse(response.body.lines.to_a[1..-1].join) do |row|
          br = BatchResult.new
          br.id = row[0]
          br.success = row[1].to_b
          br.created = row[2].to_b
          br.error = row[3]
          
          result << br
        end
      end
      
      result
    end
    
    def query_result(job_id, batch_id, result_id, result_ids)
      headers = {"Content-Type" => "text/csv; charset=UTF-8"}
      response = http_get("job/#{job_id}/batch/#{batch_id}/result/#{result_id}", headers)
      puts "",response,""
      
      lines = response.body.lines.to_a
      headers = CSV.parse_line(lines.shift).collect { |header| header.to_sym }
      
      result = QueryResultCollection.new(self, job_id, batch_id, lines.length, result_id, result_ids)
      
      #CSV.parse(lines.join, :headers => headers, :converters => [:all, lambda{|s| s.to_b if s.kind_of? String }]) do |row|
      CSV.parse(lines.join, :headers => headers) do |row|
        result << Hash[row.headers.zip(row.fields)]
      end
      puts "",result,""
      result
    end
    
    def close_job(jobId)
      xml = '<?xml version="1.0" encoding="utf-8"?>'
      xml += '<jobInfo xmlns="http://www.force.com/2009/06/asyncapi/dataload">'
      xml += "<state>Closed</state>"
      xml += "</jobInfo>"
      
      #puts "","",xml
      response = http_post("job/#{jobId}", xml)
      data = XmlSimple.xml_in(response.body, :ForceArray => false)
      #puts "","",response
      
      job = Job.new
      job.id = data['id']
      job.state = data['state']
      job
    end
    
    def job_info(jobId)
      response = http_get("job/#{jobId}")
      data = XmlSimple.xml_in(response.body, :ForceArray => false)
      #puts "","",response
      
      job = Job.new
      job.id = data['id']
      job.state = data['state']
      job
    end
    
    def http_post(path, body, headers={})
      host = self.host
      
      headers = {'Content-Type' => 'application/xml'}.merge(headers)
      
      if @session_id
        headers['X-SFDC-Session'] = @session_id
        host = self.instance_host
        path = "#{@api_path_prefix}#{path}"
      end
      
      response = https_request(host).post(path, body, headers)
      
      if response.is_a?(Net::HTTPSuccess)
        response
      else
        raise SalesforceError.new(response)
      end
    end
    
    def http_get(path, headers={})
      path = "#{@api_path_prefix}#{path}"
      
      headers = {'Content-Type' => 'application/xml'}.merge(headers)
      
      if @session_id
        headers['X-SFDC-Session'] = @session_id
      end
      
      https_request(self.instance_host).get(path, headers)
    end
    
    def https_request(host)
      req = Net::HTTP.new(host, 443)
      req.use_ssl = true
      req.verify_mode = OpenSSL::SSL::VERIFY_NONE
      req
    end
    
    def instance_id(url)
      url.match(/:\/\/([a-zA-Z0-9-]{2,}).salesforce/)[1]
    end
    
    def upsert(sobject, external_id, data, concurrency_mode=nil)
      job = add_job(:operation => :upsert, :sobject => sobject, :concurrency_mode => concurrency_mode, :external_id_field_name => external_id)
      batch = add_batch(job.id, data)
      job = close_job(job.id)
      
      while true
        batch = batch_info(job.id, batch.id)
        
        break if !batch.queued? && !batch.in_progress?
        
        sleep 2
      end
      
      batch_result_list(job.id, batch.id)
    end
    
  end
end