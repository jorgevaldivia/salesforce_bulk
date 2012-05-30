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
    
    # The API version the client is using. Defaults to 23.0.
    attr_accessor :version
    
    def initialize(options={})
      self.username = options[:username]
      self.password = "#{options[:password]}#{options[:token]}"
      self.token = options[:token]
      
      options = {:debugging => false, :host => 'login.salesforce.com', :version => '23.0'}.merge(options)
      
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
      
      raise SalesforceError.new(response) unless response.is_a?(Net::HTTPSuccess)
      
      data = XmlSimple.xml_in(response.body)
      
      @session_id = data['Body'][0]['loginResponse'][0]['result'][0]['sessionId'][0]
      
      url = data['Body'][0]['loginResponse'][0]['result'][0]['serverUrl'][0]
      
      self.instance_host = "#{instance_id(url)}.salesforce.com"
    end
    
    def job(operation, sobject, id, mode=:parallel)
      Job.new(operation, sobject, id, mode, self)
    end
    
    def http_post(path, xml, headers={})
      host = self.host
      
      headers = {'Content-Type' => 'application/xml'}.merge(headers)
      
      if @session_id
        headers['X-SFDC-Session'] = @session_id
        host = self.instance_host
        path = "#{@api_path_prefix}#{path}"
      end
      
      https_request(host).post(path, xml, headers)
    end
    
    def http_get(path, headers={})
      path = path || "#{@api_path_prefix}#{path}"
      
      headers = {'Content-Type' => 'application/xml'}.merge(headers)
      
      if @session_id
        headers['X-SFDC-Session'] = @session_id
      end
      
      https_request(self.host).get(path, headers)
    end
    
    def https_request(host)
      req = Net::HTTP.new(host, 443)
      req.use_ssl = true
      req.verify_mode = OpenSSL::SSL::VERIFY_NONE
      req
    end
    
    def instance_id(url)
      url.match(/https:\/\/([a-z]{2,2}[0-9]{1,2})-api/)[1]
    end
    
  end
end