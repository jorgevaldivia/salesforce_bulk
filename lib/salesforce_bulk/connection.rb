module SalesforceBulk

  class Connection

    @@XML_HEADER = '<?xml version="1.0" encoding="utf-8" ?>'
    @@API_VERSION = nil
    @@LOGIN_HOST = 'login.salesforce.com'
    @@INSTANCE_HOST = nil # Gets set in login()

    def initialize(username, password, api_version, in_sandbox)
      @username = username
      @password = password
      @session_id = nil
      @server_url = nil
      @instance = nil
      @@API_VERSION = api_version
      @@LOGIN_PATH = "/services/Soap/u/#{@@API_VERSION}"
      @@PATH_PREFIX = "/services/async/#{@@API_VERSION}/"
      @@LOGIN_HOST = 'test.salesforce.com' if in_sandbox

      login()
    end

    #private

    def login()

      xml = '<?xml version="1.0" encoding="utf-8" ?>'
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

      response = post_xml(@@LOGIN_HOST, @@LOGIN_PATH, xml, headers)
      response_parsed = XmlSimple.xml_in(response)

      @session_id = response_parsed['Body'][0]['loginResponse'][0]['result'][0]['sessionId'][0]
      @server_url = response_parsed['Body'][0]['loginResponse'][0]['result'][0]['serverUrl'][0]
      @instance = parse_instance()

      @@INSTANCE_HOST = "#{@instance}.salesforce.com"
    end

    def post_xml(host, path, xml, headers)

      host = host || @@INSTANCE_HOST

      if host != @@LOGIN_HOST # Not login, need to add session id to header
        headers['X-SFDC-Session'] = @session_id;
        #puts "session id is: #{@session_id} --- #{headers.inspect}\n"
        path = "#{@@PATH_PREFIX}#{path}"
      end

      #puts "#{host} -- #{path} -- #{headers.inspect}\n"

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
      @server_url =~ /https:\/\/([a-z]{2,2}[0-9]{1,2})-api/
      @instance = $~.captures[0]
    end

  end

end
