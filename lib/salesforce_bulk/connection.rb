module SalesforceBulk
  class Connection
    LOGIN_HOST = 'login.salesforce.com'

    def initialize(username, password, api_version, sandbox)
      @username = username
      @password = password
      @api_version = api_version
      @sandbox = sandbox
      login
    end

    def login
      r = SalesforceBulk::Http::Request.create_login(
        @sandbox,
        @username,
        @password,
        @api_version)

      response = request r
      response_parsed = parse_response response

      @session_id = response_parsed['Body'][0]['loginResponse'][0]['result'][0]['sessionId'][0]
      @server_url = response_parsed['Body'][0]['loginResponse'][0]['result'][0]['serverUrl'][0]
      @instance = parse_instance()
    end

    def create_job operation, sobject, external_field
      response = request(SalesforceBulk::Http::Request.create_job(
        @instance,
        @session_id,
        operation,
        sobject,
        @api_version,
        external_field))

      response_parsed = parse_response response
      response_parsed['id'][0]
    end

    def close_job job_id
      response = request(SalesforceBulk::Http::Request.close_job(
        @instance,
        @session_id,
        job_id,
        @api_version))

      puts "====="
      puts "close_job response: #{response.inspect}"
      puts "====="

      response_parsed = parse_response response
      response_parsed['id'][0]
    end

    def add_batch job_id, records
      keys = records.first.keys

      rows = keys.to_csv
      records.each do |r|
        fields = []
        keys.each do |k|
          fields.push(r[k])
        end
        rows << fields.to_csv
      end

      r = SalesforceBulk::Http::Request.add_batch(
        @instance,
        @session_id,
        job_id,
        rows,
        @api_version)

      response = request(r)
      puts '+++++'
      puts "batch: #{response.inspect}"
      puts '+++++'
      response_parsed = XmlSimple.xml_in(response)

      response_parsed['id'][0]
    end

    def request r
      puts r.inspect
      https(r.host).post(r.path, r.body, r.headers).body
    end

    def get_request(host, path, headers)
      https(host).get(path, headers).body
    end

    def https(host)
      req = Net::HTTP.new(host, 443)
      req.use_ssl = true
      req.verify_mode = OpenSSL::SSL::VERIFY_NONE
      req
    end

    def parse_instance
      #TODO make more ruby like
      @server_url =~ /https:\/\/([a-z]{2,2}[0-9]{1,2})-api/
      @instance = $~.captures[0]
    end

    def parse_response response
      response_parsed = XmlSimple.xml_in(response)

      if response.downcase.include?('faultstring') || response.downcase.include?('exceptionmessage')
        begin
          
          if response.downcase.include?('faultstring')
            error_message = response_parsed['Body'][0]['Fault'][0]['faultstring'][0]
          elsif response.downcase.include?('exceptionmessage')
            error_message = response_parsed['exceptionMessage'][0]
          end

        rescue
          raise "An unknown error has occured within the salesforce_bulk gem. This is most likely caused by bad request, but I am unable to parse the correct error message. Here is a dump of the response for your convenience. #{response}"
        end

        raise error_message
      end

      response_parsed
    end
  end
end