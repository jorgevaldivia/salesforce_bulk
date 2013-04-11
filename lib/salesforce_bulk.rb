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
      start_job('upsert', sobject, records, external_field)
    end

    def update(sobject, records)
      start_job('update', sobject, records)
    end

    def create(sobject, records)
      start_job('insert', sobject, records)
    end

    def delete(sobject, records)
      start_job('delete', sobject, records)
    end

    def query(sobject, query)
      job_id = @connection.create_job(
        'query',
        sobject,
        nil)
      batch_id = @connection.add_query(job_id, query)
      @connection.close_job job_id
      batch_reference = SalesforceBulk::Batch.new @connection, job_id, batch_id
      batch_reference.init_result_id
      batch_reference.final_status
    end

    private
    def start_job(operation, sobject, records, external_field=nil)
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