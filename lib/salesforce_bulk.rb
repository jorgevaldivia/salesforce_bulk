require 'net/https'
require 'xmlsimple'
require 'csv'
require "salesforce_bulk/version"
require 'salesforce_bulk/job'
require 'salesforce_bulk/connection'

module SalesforceBulk
  # Your code goes here...
  class Api

    @@SALESFORCE_API_VERSION = '24.0'

    def initialize(username, password, api_version=@@SALESFORCE_API_VERSION, in_sandbox=false)
      @connection = SalesforceBulk::Connection.new(username, password, api_version, in_sandbox)
    end

    def upsert(sobject, records, external_field, wait=false)
      self.do_operation('upsert', sobject, records, external_field, wait)
    end

    def update(sobject, records, wait=false)
      self.do_operation('update', sobject, records, nil, wait)
    end
    
    def create(sobject, records, wait=false)
      self.do_operation('insert', sobject, records, nil, wait)
    end

    def delete(sobject, records, wait=false)
      self.do_operation('delete', sobject, records, nil, wait)
    end

    def query(sobject, query)
      self.do_operation('query', sobject, query, nil)
    end

    def pk_query(sobject, query)
      self.do_operation('query', sobject, query, nil, false, true)
    end

    def do_operation(operation, sobject, records, external_field, wait=false, pk_chunk=false)
      job = SalesforceBulk::Job.new(operation, sobject, records, external_field, @connection)

      # TODO: put this in one function
      job_id = job.create_job(pk_chunk)
      if(operation == "query")
        batch_id = job.add_query()
      else
        batch_id = job.add_batch()
      end
     
      if wait or operation == 'query'
        while true
          state = job.check_batch_status()
          if state != "Queued" && state != "InProgress"
            break
          end
          sleep(2) # wait x seconds and check again
        end
        if !pk_chunk && state == 'Completed'
          job.get_batch_result()
          job.close_job()
          return job
        elsif pk_chunk && state == 'NotProcessed'
          job.fetch_pk_batch_ids()
          job.close_job()
          return job
        else
          job.result.message = "There is an error in your job. The response returned a state of #{state}. Please check your query/parameters and try again."
          job.result.success = false
          job.close_job()
          return job
        end
        
      else
        job.close_job()
        return job
      end

    end

    def parse_batch_result result
      begin
        CSV.parse(result, :headers => true)
      rescue
        result
      end
    end

  end  # End class
end # End module
