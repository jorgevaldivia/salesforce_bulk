#encoding: utf-8
require 'spec_helper'

describe SalesforceBulk::Http do
  describe '#process_http_request' do
    let(:post_request) do 
      SalesforceBulk::Http::Request.new(
        :post,
        'test.host',
        '/',
        'post body',
        {'X-SFDC-Session' => 'super_secret'})
    end
  
    let(:get_request) do 
      SalesforceBulk::Http::Request.new(:get, 'test.host', '/', '', [])
    end
  
    it 'should return a response object' do
       expected_body = 'correct result'
        stub_request(:post, 'https://test.host').
          with(
            body: post_request.body,
            headers: post_request.headers).
          to_return(:body => expected_body)
       res = SalesforceBulk::Http.process_http_request(post_request)
       expect(res).to eq(expected_body)
    end
  end

  describe '#create_login' do
    let(:login_error_message) do
      'INVALID_LOGIN: Invalid username, password, security token;' \
      'or user locked out.'
    end

    let(:sf_instance) {'cs7'}

    let(:login_success) do
      %Q{<?xml version="1.0" encoding="UTF-8"?>
          <soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns="urn:partner.soap.sforce.com" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
            <soapenv:Body>
              <loginResponse>
                <result>
                  <metadataServerUrl>https://#{sf_instance}-api.salesforce.com/services/Soap/m/27.0/00EU00000095Y5b</metadataServerUrl>
                  <passwordExpired>false</passwordExpired>
                  <sandbox>true</sandbox>
                  <serverUrl>https://#{sf_instance}-api.salesforce.com/services/Soap/u/27.0/00EU00000095Y5b</serverUrl>
                  <sessionId>00DM00000099X9a!AQ7AQJ9BjrYfF2h_G9_VERsCRVjTMAPaWjz2zuqqRBduYvKCmHexVbKdtxFMrgTnV9Xi.M80AhIkjnwuEVxI00ChG09._Q_X</sessionId>
                  <userId>005K001100243YPIAY</userId>
                  <userInfo>
                    <accessibilityMode>false</accessibilityMode>
                    <currencySymbol xsi:nil="true"/>
                    <orgAttachmentFileSizeLimit>2621440</orgAttachmentFileSizeLimit>
                    <orgDefaultCurrencyIsoCode xsi:nil="true"/>
                    <orgDisallowHtmlAttachments>false</orgDisallowHtmlAttachments>
                    <orgHasPersonAccounts>false</orgHasPersonAccounts>
                    <organizationId>00ID0000OrgFoo</organizationId>
                    <organizationMultiCurrency>true</organizationMultiCurrency>
                    <organizationName>Hinz &amp; Kunz</organizationName>
                    <profileId>00eA0000000nJEY</profileId>
                    <roleId xsi:nil="true"/>
                    <sessionSecondsValid>3600</sessionSecondsValid>
                    <userDefaultCurrencyIsoCode>EUR</userDefaultCurrencyIsoCode>
                    <userEmail>theadmin@example.com</userEmail>
                    <userFullName>John Doe</userFullName>
                    <userId>005D0000002b3SPIAY</userId>
                    <userLanguage>de</userLanguage>
                    <userLocale>de_DE_EURO</userLocale>
                    <userName>theadmin@exammple.com.euvconfig</userName>
                    <userTimeZone>Europe/Berlin</userTimeZone>
                    <userType>Standard</userType>
                    <userUiSkin>Theme42</userUiSkin>
                  </userInfo>
                </result>
              </loginResponse>
            </soapenv:Body>
          </soapenv:Envelope>}
    end

    let(:login_error) do
      %Q{<?xml version="1.0" encoding="UTF-8"?>
        <soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" 
        xmlns:sf="urn:fault.partner.soap.sforce.com" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
          <soapenv:Body>
            <soapenv:Fault>
              <faultcode>INVALID_LOGIN</faultcode>
              <faultstring>#{login_error_message}</faultstring>
              <detail>
                <sf:LoginFault xsi:type="sf:LoginFault">
                  <sf:exceptionCode>INVALID_LOGIN</sf:exceptionCode>
                  <sf:exceptionMessage>Invalid username, password, │Your bundle is complete!security token; or user locked out.
                  </sf:exceptionMessage>
                </sf:LoginFault>
              </detail>
            </soapenv:Fault>
          </soapenv:Body>
        </soapenv:Envelope>}
    end

    it 'should raise an error for faulty login' do
      SalesforceBulk::Http.should_receive(:process_http_request).
        and_return(login_error)
      expect{ SalesforceBulk::Http.login('a','b','c', 'd') }.
        to raise_error(RuntimeError, login_error_message)
    end

    it 'should return hash for correct login' do
      SalesforceBulk::Http.should_receive(:process_http_request).
        and_return(login_success)
      result = SalesforceBulk::Http.login('a','b','c', 'd')
      expect(result).to be_a(Hash)
      expect(result).to have_key(:session_id)
      expect(result).to have_key(:server_url)
      expect(result[:instance]).to eq(sf_instance)
    end
  end

  describe '#create_job' do
    let(:create_job_success) do
      %Q{<?xml version="1.0" encoding="UTF-8"?>
          <jobInfo xmlns="http://www.force.com/2009/06/asyncapi/dataload">
            <id>750D0000000002lIAA</id>
            <operation>upsert</operation>
            <object>Contact</object>
            <createdById>005D0000001ALVFIA4</createdById>
            <createdDate>2013-04-10T15:52:02.000Z</createdDate>
            <systemModstamp>2013-04-10T15:52:02.000Z</systemModstamp>
            <state>Open</state>
            <externalIdFieldName>my_external_field__c</externalIdFieldName>
            <concurrencyMode>Parallel</concurrencyMode>
            <contentType>CSV</contentType>
            <numberBatchesQueued>0</numberBatchesQueued>
            <numberBatchesInProgress>0</numberBatchesInProgress>
            <numberBatchesCompleted>0</numberBatchesCompleted>
            <numberBatchesFailed>0</numberBatchesFailed>
            <numberBatchesTotal>0</numberBatchesTotal>
            <numberRecordsProcessed>0</numberRecordsProcessed>
            <numberRetries>0</numberRetries>
            <apiVersion>27.0</apiVersion>
            <numberRecordsFailed>0</numberRecordsFailed>
            <totalProcessingTime>0</totalProcessingTime>
            <apiActiveProcessingTime>0</apiActiveProcessingTime>
            <apexProcessingTime>0</apexProcessingTime>
          </jobInfo>}
    end

    it 'should return hash for creating job' do
      SalesforceBulk::Http.should_receive(:process_http_request).
        and_return(create_job_success)
      result = SalesforceBulk::Http.create_job('a','b','c','d', 'e')
      expect(result).to be_a(Hash)
      expect(result).to have_key(:id)
      expect(result).to have_key(:operation)
    end
  end

  describe '#add_batch' do
    let(:add_batch_success) do
      %Q{
        <?xml version="1.0" encoding="UTF-8"?>
          <batchInfo xmlns="http://www.force.com/2009/06/asyncapi/dataload">
            <id>750M0000000B1Z6IAL</id>
            <jobId>751K00000009x71IAA</jobId>
            <state>Queued</state>
            <createdDate>2013-04-10T15:53:46.000Z</createdDate>
            <systemModstamp>2013-04-10T15:53:46.000Z</systemModstamp>
            <numberRecordsProcessed>0</numberRecordsProcessed>
            <numberRecordsFailed>0</numberRecordsFailed>
            <totalProcessingTime>0</totalProcessingTime>
            <apiActiveProcessingTime>0</apiActiveProcessingTime>
            <apexProcessingTime>0</apexProcessingTime>
          </batchInfo>
      }
    end

    it 'should return hash for adding batch' do
      SalesforceBulk::Http.should_receive(:process_http_request).
        and_return(add_batch_success)
      result = SalesforceBulk::Http.add_batch(:post,'a','b','c','d')
      expect(result).to be_a(Hash)
      expect(result).to have_key(:id)
      expect(result).to have_key(:job_id)
      expect(result).to have_key(:state)
    end
  end

  describe '#close_job' do
    let(:close_job_success) do
      %Q{<?xml version="1.0" encoding="UTF-8"?>
          <jobInfo xmlns="http://www.force.com/2009/06/asyncapi/dataload">
            <id>750D0000000002jIAA</id>
            <operation>upsert</operation>
            <object>Contact</object>
            <createdById>005D0000002b3SPIAY</createdById>
            <createdDate>2013-04-10T16:27:56.000Z</createdDate>
            <systemModstamp>2013-04-10T16:27:56.000Z</systemModstamp>
            <state>Closed</state>
            <externalIdFieldName>my_external_id__c</externalIdFieldName>
            <concurrencyMode>Parallel</concurrencyMode>
            <contentType>CSV</contentType>
            <numberBatchesQueued>0</numberBatchesQueued>
            <numberBatchesInProgress>0</numberBatchesInProgress>
            <numberBatchesCompleted>1</numberBatchesCompleted>
            <numberBatchesFailed>0</numberBatchesFailed>
            <numberBatchesTotal>1</numberBatchesTotal>
            <numberRecordsProcessed>4</numberRecordsProcessed>
            <numberRetries>0</numberRetries>
            <apiVersion>27.0</apiVersion>
            <numberRecordsFailed>0</numberRecordsFailed>
            <totalProcessingTime>838</totalProcessingTime>
            <apiActiveProcessingTime>355</apiActiveProcessingTime>
            <apexProcessingTime>253</apexProcessingTime>
          </jobInfo>}
    end

    it 'should return hash for closing job' do
      SalesforceBulk::Http.should_receive(:process_http_request).
        and_return(close_job_success)
      result = SalesforceBulk::Http.close_job('a','b','c','d')
      expect(result).to be_a(Hash)
      expect(result).to have_key(:id)
      expect(result).to have_key(:object)
      expect(result).to have_key(:operation)
      expect(result).to have_key(:state)
      expect(result).to have_key(:content_type)
    end
  end

  describe '#add_batch' do
    let(:invalid_session_id) do
      %Q{<?xml version="1.0" encoding="UTF-8"?>
        <error xmlns="http://www.force.com/2009/06/asyncapi/dataload">
          <exceptionCode>InvalidSessionId</exceptionCode>
          <exceptionMessage>Invalid session id</exceptionMessage>
        </error>}
    end

    it 'should raise an exception on faulty authorization' do
      SalesforceBulk::Http.should_receive(:process_http_request).
        and_return(invalid_session_id)
      expect{SalesforceBulk::Http.query_batch('a','b','c','d','e')}.
        to raise_error(RuntimeError, 'InvalidSessionId: Invalid session id')
    end
  end
end