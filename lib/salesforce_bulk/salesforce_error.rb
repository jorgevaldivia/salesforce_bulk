module SalesforceBulk
  # An exception raised when any non successful request is made through the Salesforce Bulk API.
  class SalesforceError < StandardError
    # The Net::HTTPResponse instance from the API call.
    attr_accessor :response
    # The status code from the server response body.
    attr_accessor :error_code
    
    def initialize(response)
      self.response = response
      
      data = XmlSimple.xml_in(response.body)
      
      if data
        message = url = data['Body'][0]['Fault'][0]['faultstring'][0]
        self.error_code = response.code
      end
      
      super(message)
    end
  end
end