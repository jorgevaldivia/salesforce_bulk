module SalesforceBulk

  class Job

    attr :result, :pk_batch_ids

    def initialize(operation, sobject, records, external_field, connection)

      @@operation = operation
      @@sobject = sobject
      @@external_field = external_field
      @@records = records
      @@connection = connection
      @@XML_HEADER = '<?xml version="1.0" encoding="utf-8" ?>'

      # @result = {"errors" => [], "success" => nil, "records" => [], "raw" => nil, "message" => 'The job has been queued.'}
      @result = JobResult.new
      @pk_batch_ids = []

    end

    def create_job(pk_chunk=false)
      @@pk_chunk = pk_chunk      

      xml = "#{@@XML_HEADER}<jobInfo xmlns=\"http://www.force.com/2009/06/asyncapi/dataload\">"
      xml += "<operation>#{@@operation}</operation>"
      xml += "<object>#{@@sobject}</object>"
      if !@@external_field.nil? # This only happens on upsert
        xml += "<externalIdFieldName>#{@@external_field}</externalIdFieldName>"
      end
      xml += "<contentType>CSV</contentType>"
      xml += "</jobInfo>"

      path = "job"
      headers = Hash['Content-Type' => 'application/xml; charset=utf-8']

      if pk_chunk
        headers['Sforce-Enable-PKChunking'] = "chunkSize=50000;"
      end

      response = @@connection.post_xml(nil, path, xml, headers)
      response_parsed = @@connection.parse_response response

      @@job_id = response_parsed['id'][0]
    end

    def close_job()
      xml = "#{@@XML_HEADER}<jobInfo xmlns=\"http://www.force.com/2009/06/asyncapi/dataload\">"
      xml += "<state>Closed</state>"
      xml += "</jobInfo>"

      path = "job/#{@@job_id}"
      headers = Hash['Content-Type' => 'application/xml; charset=utf-8']

      response = @@connection.post_xml(nil, path, xml, headers)
      response_parsed = XmlSimple.xml_in(response)

      #job_id = response_parsed['id'][0]
    end

    def add_query
      path = "job/#{@@job_id}/batch/"
      headers = Hash["Content-Type" => "text/csv; charset=UTF-8"]
      response = @@connection.post_xml(nil, path, @@records, headers)
      response_parsed = XmlSimple.xml_in(response)

      @@batch_id = response_parsed['id'][0]
    end

    def add_batch()
      keys = @@records.first.keys
      
      output_csv = keys.to_csv

      @@records.each do |r|
        fields = Array.new
        keys.each do |k|
          fields.push(r[k])
        end

        row_csv = fields.to_csv
        output_csv += row_csv
      end

      path = "job/#{@@job_id}/batch/"
      headers = Hash["Content-Type" => "text/csv; charset=UTF-8"]
      
      response = @@connection.post_xml(nil, path, output_csv, headers)
      response_parsed = XmlSimple.xml_in(response)

      @@batch_id = response_parsed['id'][0]
    end

    def fetch_pk_batch_ids()
      path = "job/#{@@job_id}/batch"
      headers = Hash.new

      response = @@connection.get_request(nil, path, headers)
      response_parsed = XmlSimple.xml_in(response)
    
      response_parsed['batchInfo'].each do |batch|
        next if batch['id'][0] == @@batch_id
        @pk_batch_ids << batch['id'][0]
      end 
      @pk_batch_ids
    end

    def check_batch_status(batch_id=@@batch_id)
      path = "job/#{@@job_id}/batch/#{batch_id}"
      headers = Hash.new

      response = @@connection.get_request(nil, path, headers)
      response_parsed = XmlSimple.xml_in(response)
      
      begin
        #puts "check: #{response_parsed.inspect}\n"
        response_parsed['state'][0]
      rescue Exception => e
        #puts "check: #{response_parsed.inspect}\n"

        nil
      end
    end
    
    def get_batch_result(batch_id=@@batch_id)
      path = "job/#{@@job_id}/batch/#{batch_id}/result"
      headers = Hash["Content-Type" => "text/xml; charset=UTF-8"]

      response = @@connection.get_request(nil, path, headers)
      if(@@operation == "query") # The query op requires us to do another request to get the results
        response_parsed = XmlSimple.xml_in(response)
        result_id = response_parsed["result"][0]

        path = "job/#{@@job_id}/batch/#{@@batch_id}/result/#{result_id}"
        headers = Hash.new
        headers = Hash["Content-Type" => "text/xml; charset=UTF-8"]
        
        response = @@connection.get_request(nil, path, headers)
      end

      parse_results response
      
      response = response.lines.to_a[1..-1].join
      # csvRows = CSV.parse(response, :headers => true)
    end

    def get_pk_batch_result_when_completed(batch_id)
      while true 
        state = check_batch_status(batch_id)
        if state != "Queued" && state != "InProgress"
          break
        end
        sleep(2)
      end
      
      if state == 'Completed'
        get_batch_result(batch_id)
      else
        @result.message = "There is an error in your job. The response returned a state of #{state}. Please check your query/parameters and try again."
        @result.success = false
      end
    end


    def parse_results response
      # if pk-chunking, replace old results with new vs. appending 
      if (@@pk_chunk and @@operation == "query")
        @result = JobResult.new
      end

      @result.success = true
      @result.raw = response.lines.to_a[1..-1].join
      csvRows = CSV.parse(response, :headers => true)

      csvRows.each_with_index  do |row, index|
        if @@operation != "query"
          row["Created"] = row["Created"] == "true" ? true : false
          row["Success"] = row["Success"] == "true" ? true : false
        end

        @result.records.push row
        if row["Success"] == false
          @result.success = false 
          @result.errors.push({"#{index}" => row["Error"]}) if row["Error"]
        end
      end

      @result.message = "The job has been closed."

    end

  end

  class JobResult
    attr_writer :errors, :success, :records, :raw, :message
    attr_reader :errors, :success, :records, :raw, :message

    def initialize
      @errors = []
      @success = nil
      @records = []
      @raw = nil
      @message = 'The job has been queued.'
    end

    def success?
      @success
    end

    def has_errors?
      @errors.count > 0
    end
  end

end
