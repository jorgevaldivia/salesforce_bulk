require 'net/https'
require 'nori'
require 'csv'

module SalesforceBulk
  module Http
    extend self

    def login *args
      r = Http::Request.login(*args)
      process_soap_response(nori.parse(process_http_request(r)))
    end

    def create_job *args
      r = Http::Request.create_job(*args)
      process_xml_response(nori.parse(process_http_request(r)))
    end

    def close_job *args
      r = Http::Request.close_job(*args)
      process_xml_response(nori.parse(process_http_request(r)))
    end

    def add_batch *args
      r = Http::Request.add_batch(*args)
      process_xml_response(nori.parse(process_http_request(r)))
    end

    def query_batch *args
      r = Http::Request.query_batch(*args)
      process_xml_response(nori.parse(process_http_request(r)))
    end

    def query_batch_result_id *args
      r = Http::Request.query_batch_result_id(*args)
      process_xml_response(nori.parse(process_http_request(r)))
    end

    def query_batch_result_data *args
      r = Http::Request.query_batch_result_data(*args)
      process_csv_response(process_http_request(r))
    end

    def process_http_request(r)
      http = Net::HTTP.new(r.host, 443)
      http.use_ssl = true
      http.verify_mode = OpenSSL::SSL::VERIFY_NONE
      http_request = Net::HTTP.
      const_get(r.http_method.capitalize).
        new(r.path, r.headers)
      http_request.body = r.body if r.body
      http.request(http_request).body
    end

    private
    def nori
      Nori.new(
        :advanced_typecasting => true,
        :strip_namespaces => true,
        :convert_tags_to => lambda { |tag| tag.snakecase.to_sym })
    end

    def process_xml_response res
      if res[:error]
        raise "#{res[:error][:exception_code]}: #{res[:error][:exception_message]}"
      end

      res.values.first
    end

    def process_csv_response res
      CSV.parse(res.gsub(/\n\s+/, "\n"), headers: true).map{|r| r.to_hash}
    end

    def process_soap_response res
      raw_result = res.fetch(:body){res.fetch(:envelope).fetch(:body)}
      raise raw_result[:fault][:faultstring] if raw_result[:fault]

      login_result = raw_result[:login_response][:result]
      instance = login_result[:server_url][/^https?:\/\/(\w+)-api/, 1]
      login_result.merge(instance: instance)
    end

    class Request
      attr_reader :path
      attr_reader :host
      attr_reader :body
      attr_reader :headers
      attr_reader :http_method

      def initialize http_method, host, path, body, headers
        @http_method  = http_method
        @host         = host
        @path         = path
        @body         = body
        @headers      = headers
      end

      def self.login sandbox, username, password, api_version
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
        Http::Request.new(
          :post,
          host,
          "/services/Soap/u/#{api_version}",
          body,
          headers)
      end

      def self.create_job instance, session_id, operation, sobject, api_version, external_field = nil
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
        headers = {
          'Content-Type' => 'application/xml; charset=utf-8',
          'X-SFDC-Session' => session_id}
        Http::Request.new(
          :post,
          "#{instance}.salesforce.com",
          "/services/async/#{api_version}/job",
          body,
          headers)
      end

      def self.close_job instance, session_id, job_id, api_version
        body = %Q{<?xml version="1.0" encoding="utf-8" ?>
          <jobInfo xmlns="http://www.force.com/2009/06/asyncapi/dataload">
            <state>Closed</state>
          </jobInfo>
        }
        headers = {
          'Content-Type' => 'application/xml; charset=utf-8',
          'X-SFDC-Session' => session_id}
        Http::Request.new(
          :post,
          "#{instance}.salesforce.com",
          "/services/async/#{api_version}/job/#{job_id}",
          body,
          headers)
      end

      def self.add_batch instance, session_id, job_id, data, api_version
        headers = {'Content-Type' => 'text/csv; charset=UTF-8', 'X-SFDC-Session' => session_id}
        Http::Request.new(
          :post,
          "#{instance}.salesforce.com",
          "/services/async/#{api_version}/job/#{job_id}/batch",
          data,
          headers)
      end

      def self.query_batch instance, session_id, job_id, batch_id, api_version
        headers = {'X-SFDC-Session' => session_id}
        Http::Request.new(
          :get,
          "#{instance}.salesforce.com",
          "/services/async/#{api_version}/job/#{job_id}/batch/#{batch_id}",
          nil,
          headers)
      end

      def self.query_batch_result_id instance, session_id, job_id, batch_id, api_version
        headers = {
          'Content-Type' => 'application/xml; charset=utf-8',
          'X-SFDC-Session' => session_id}
        Http::Request.new(
          :get,
          "#{instance}.salesforce.com",
          "/services/async/#{api_version}/job/#{job_id}/batch/#{batch_id}/result",
          nil,
          headers)
      end

      def self.query_batch_result_data(instance,
        session_id,
        job_id,
        batch_id,
        result_id,
        api_version)
        headers = {
          'Content-Type' => 'text/csv; charset=UTF-8',
          'X-SFDC-Session' => session_id}
        Http::Request.new(
          :get,
          "#{instance}.salesforce.com",
          "/services/async/#{api_version}" \
            "/job/#{job_id}/batch/#{batch_id}/result/#{result_id}",
          nil,
          headers)
      end
    end
  end
end