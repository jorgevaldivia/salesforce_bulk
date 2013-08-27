module SalesforceBulk

  class Connection

    @@XML_HEADER = '<?xml version="1.0" encoding="utf-8" ?>'
    @@API_VERSION = nil
    @@LOGIN_HOST = 'login.salesforce.com'
    @@INSTANCE_HOST = nil # Gets set in login()

    def initialize(sid, instance, orgid, api_version, in_sandbox)
      @session_id = sid
      @instance = instance
      @server_url = "https://#{instance}.salesforce.com/services/Soap/u/28.0/#{orgid}"
      @@INSTANCE_HOST = "#{instance}.salesforce.com"
      @@API_VERSION = api_version
      @@LOGIN_PATH = "/services/Soap/u/#{@@API_VERSION}"
      @@PATH_PREFIX = "/services/async/#{@@API_VERSION}/"
      @@LOGIN_HOST = 'test.salesforce.com' if in_sandbox
    end

    #private
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
      @server_url =~ /https:\/\/([a-z]{2,2}[0-9]{1,2})(-api)?/
      if $~.nil?
        # Check for a "My Domain" subdomain
        @server_url =~ /https:\/\/[a-zA-Z\-0-9]*.([a-z]{2,2}[0-9]{1,2})(-api)?/
        if $~.nil?
          raise "Unable to parse Salesforce instance from server url (#{@server_url})."
        else
          @instance = $~.captures[0]
        end
      else
        @instance = $~.captures[0]
      end
    end

    def parse_response response
      response_parsed = XmlSimple.xml_in(response)

      if response.downcase.include?("faultstring") || response.downcase.include?("exceptionmessage")
        begin
          
          if response.downcase.include?("faultstring")
            error_message = response_parsed["Body"][0]["Fault"][0]["faultstring"][0]
          elsif response.downcase.include?("exceptionmessage")
            error_message = response_parsed["exceptionMessage"][0]
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
