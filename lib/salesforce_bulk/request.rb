module SalesforceBulk
  class Request
    attr_reader :path
    attr_reader :host
    attr_reader :body
    attr_reader :headers

    def initialize host, path, body, headers
      @host = host
      @path = path
      @body = body
      @headers = headers
    end

    def self.create_login sandbox, username, password, api_version = '27.0'
      body =  %Q{<?xml version="1.0" encoding="utf-8" ?>
      <env:Envelope xmlns:xsd="http://www.w3.org/2001/XMLSchema"
          xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
          xmlns:env="http://schemas.xmlsoap.org/soap/envelope/">
        <env:Body>
          <n1:login xmlns:n1="urn:partner.soap.sforce.com">
            <n1:username>#{username}</n1:username>
            <n1:password>#{password}</n1:password>
          </n1:login>
        </env:Body>
      </env:Envelope>}
      headers = {
        'Content-Type' => 'text/xml; charset=utf-8',
        'SOAPAction' => 'login'
      }
      host = sandbox ? 'test.salesforce.com' : 'login.salesforce.com'
      SalesforceBulk::Request.new(host,
        "/services/Soap/u/#{api_version}",
        body,
        headers)
    end

    def self.create_job instance, operation, sobject, external_field = nil
      external_field_line = external_field ?
        "<externalIdFieldName>#{external_field}</externalIdFieldName>" : nil
      body = %Q{<?xml version="1.0" encoding="utf-8" ?>
        <jobInfo xmlns="http://www.force.com/2009/06/asyncapi/dataload">
          <operation>#{operation}</operation>
          <object>#{sobject}</object>
          #{external_field_line}
          <contentType>CSV</contentType>
        </jobInfo>
      }
      headers = {'Content-Type' => 'application/xml; charset=utf-8'}
      SalesforceBulk::Request.new("#{instance}.salesforce.com",
        'job',
        body,
        headers)
    end

    def self.close_job instance, job_id
      body = %Q{<?xml version="1.0" encoding="utf-8" ?>
        <jobInfo xmlns="http://www.force.com/2009/06/asyncapi/dataload">
          <state>Closed</state>
        </jobInfo>
      }
      headers = {'Content-Type' => 'application/xml; charset=utf-8'}
      SalesforceBulk::Request.new("#{instance}.salesforce.com",
        "job/#{job_id}",
        body,
        headers)
    end

    def self.add_batch instance, job_id, data
      headers = {'Content-Type' => 'text/csv; charset=UTF-8'}
      SalesforceBulk::Request.new("#{instance}.salesforce.com",
        "job/#{job_id}/batch/",
        data,
        headers)
    end
  end
end