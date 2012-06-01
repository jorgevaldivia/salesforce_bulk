module SalesforceBulk
  # An exception raised when any non successful request is made through the Salesforce Bulk API.
  class SalesforceError < StandardError
    # The Net::HTTPResponse instance from the API call.
    attr_accessor :response
    # The status code from the server response body.
    attr_accessor :error_code
    
    def initialize(response)
      self.response = response
      
      data = XmlSimple.xml_in(response.body, 'ForceArray' => false)
      
      if data
        # seems responses for CSV requests use a different XML return format 
        # (use invalid_error.xml for reference)
        if !data['exceptionMessage'].nil?
          message = data['exceptionMessage']
        else
          # SOAP error response
          message = data['Body']['Fault']['faultstring']
        end
        
        self.error_code = response.code
      end
      
      super(message)
    end
  end
end