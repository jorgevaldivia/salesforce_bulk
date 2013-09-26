module SalesforceBulk

  class Connection

    XML_HEADER = '<?xml version="1.0" encoding="utf-8" ?>'

    def initialize(username, password, api_version, in_sandbox)
      @username = username
      @password = password
      @session_id = nil
      @server_url = nil
      @instance = nil
      @api_version = api_version

      if in_sandbox
        @login_host = 'test.salesforce.com' 
      else
        @login_host = 'login.salesforce.com'
      end

      login()
    end

    def login
      xml = XML_HEADER
      xml += "<env:Envelope xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\""
      xml += "    xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\""
      xml += "    xmlns:env=\"http://schemas.xmlsoap.org/soap/envelope/\">"
      xml += "  <env:Body>"
      xml += "    <n1:login xmlns:n1=\"urn:partner.soap.sforce.com\">"
      xml += "      <n1:username>#{@username}</n1:username>"
      xml += "      <n1:password>#{@password}</n1:password>"
      xml += "    </n1:login>"
      xml += "  </env:Body>"
      xml += "</env:Envelope>"
      
      headers = Hash['Content-Type' => 'text/xml; charset=utf-8', 'SOAPAction' => 'login']

      response = post_xml(@login_host, login_path, xml, headers)
      # response_parsed = XmlSimple.xml_in(response)
      response_parsed = parse_response response

      @session_id = response_parsed['Body'][0]['loginResponse'][0]['result'][0]['sessionId'][0]
      @server_url = response_parsed['Body'][0]['loginResponse'][0]['result'][0]['serverUrl'][0]
      @instance = parse_instance()

      @instance_host = "#{@instance}.salesforce.com"
    end

    def post_xml(host, path, xml, headers)

      host = host || @instance_host

      if host != @login_host # Not login, need to add session id to header
        headers['X-SFDC-Session'] = @session_id
        path = "#{path_prefix}#{path}"
      end

      https(host).post(path, xml, headers).body
    end

    def get_request(host, path, headers)
      host = host || @instance_host
      path = "#{path_prefix}#{path}"

      if host != @login_host # Not login, need to add session id to header
        headers['X-SFDC-Session'] = @session_id
      end

      https(host).get(path, headers).body
    end

    def https(host)
      req = Net::HTTP.new(host, 443)
      req.use_ssl = true
      req.verify_mode = OpenSSL::SSL::VERIFY_NONE
      req
    end

    def parse_instance
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

    private

    def login_path
      "/services/Soap/u/#{@api_version}"
    end

    def path_prefix
      "/services/async/#{@api_version}/"
    end

  end

end
