require 'xmlsimple'
require 'csv'
require 'salesforce_bulk/version'
require 'salesforce_bulk/batch'
require 'salesforce_bulk/http'
require 'salesforce_bulk/connection'

module SalesforceBulk
  class Api
    SALESFORCE_API_VERSION = '27.0'

    def initialize(username, password, sandbox = false, api_version = SALESFORCE_API_VERSION)
      @connection = SalesforceBulk::Connection.new(username,
        password,
        api_version,
        sandbox)
    end

    def upsert(sobject, records, external_field)
      process('upsert', sobject, records, external_field)
    end

    def update(sobject, records)
      process('update', sobject, records)
    end

    def create(sobject, records)
      process('insert', sobject, records)
    end

    def delete(sobject, records)
      process('delete', sobject, records)
    end

    # TODO won't work, need to add method `add_query`
    def query(sobject, query)
      process('query', sobject, records)
    end

    private
    def process(operation, sobject, records, external_field=nil)
      job_id = @connection.create_job(
        operation,
        sobject,
        external_field)
      batch_id = @connection.add_batch job_id, records
      @connection.close_job job_id
      SalesforceBulk::Batch.new @connection, job_id, batch_id
    end
  end
end
