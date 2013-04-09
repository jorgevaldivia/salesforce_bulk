module SalesforceBulk
  class Connection

    @@XML_HEADER = '<?xml version="1.0" encoding="utf-8" ?>'
    @@LOGIN_HOST = 'login.salesforce.com'
    @@INSTANCE_HOST = nil

    def initialize(username, password, api_version, in_sandbox)
      @username = username
      @password = password
      @session_id = nil
      @server_url = nil
      @instance = nil
      @sandbox = in_sandbox
      @@LOGIN_PATH = "/services/Soap/u/#{api_version}"
      @@PATH_PREFIX = "/services/async/#{api_version}/"
      @@LOGIN_HOST = 'test.salesforce.com' if in_sandbox
      login
    end

    def login
      r = SalesforceBulk::Request.create_login @sandbox, @username, @password

      response = request r
      response_parsed = parse_response response

      @session_id = response_parsed['Body'][0]['loginResponse'][0]['result'][0]['sessionId'][0]
      @server_url = response_parsed['Body'][0]['loginResponse'][0]['result'][0]['serverUrl'][0]
      @instance = parse_instance()

      @@INSTANCE_HOST = "#{@instance}.salesforce.com"
    end

    def create_job operation, sobject, external_field
      response = request(SalesforceBulk::Request.create_job(
        @instance,
        operation,
        sobject,
        external_field))

      response_parsed = parse_response response
      response_parsed['id'][0]
    end

    def close_job job_id
      response = request(SalesforceBulk::Request.close_job(
        @instance,
        job_id))

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

      r = SalesforceBulk::Request.add_batch(
        @instance,
        job_id,
        rows)

      response = request(r)
      response_parsed = XmlSimple.xml_in(response)

      response_parsed['id'][0]
    end

    def request r
      post_xml r.host, r.path, r.body, r.headers
    end

    def post_xml(host, path, xml, headers)
      host = host || @@INSTANCE_HOST

      if host != @@LOGIN_HOST # Not login, need to add session id to header
        headers['X-SFDC-Session'] = @session_id;
        path = "#{@@PATH_PREFIX}#{path}"
      end

      https(host).post(path, xml, headers).body
    end

    def get_request(host, path, headers)
      host = host || @@INSTANCE_HOST
      path = "#{@@PATH_PREFIX}#{path}"

      if host != @@LOGIN_HOST # Not login, need to add session id to header
        headers['X-SFDC-Session'] = @session_id;
      end

      https(host).get(path, headers).body
    end

    def https(host)
      req = Net::HTTP.new(host, 443)
      req.use_ssl = true
      req.verify_mode = OpenSSL::SSL::VERIFY_NONE
      req
    end

    def parse_instance()
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