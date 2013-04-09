require 'net/https'
require 'xmlsimple'
require 'csv'
require 'salesforce_bulk/version'
require 'salesforce_bulk/batch'
require 'salesforce_bulk/batch_status'
require 'salesforce_bulk/request'
require 'salesforce_bulk/job'
require 'salesforce_bulk/connection'

module SalesforceBulk
  class Api
    SALESFORCE_API_VERSION = '27.0'

    def initialize(username, password, in_sandbox=false)
      @connection = SalesforceBulk::Connection.new(username,
        password,
        SALESFORCE_API_VERSION,
        in_sandbox)
    end

    def upsert(sobject, records, external_field)
      self.process('upsert', sobject, records, external_field)
    end

    def update(sobject, records)
      self.process('update', sobject, records)
    end

    def create(sobject, records)
      self.process('insert', sobject, records)
    end

    def delete(sobject, records)
      self.process('delete', sobject, records)
    end

    # TODO won't work, need to add method `add_query`
    def query(sobject, query)
      self.process('query', sobject, records)
    end

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
