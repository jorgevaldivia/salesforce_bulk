module SalesforceBulk
  class Batch
    def initialize connection, job_id, batch_id
      @connection = connection
      @job_id = job_id
      @batch_id = batch_id
    end

    def final_status poll_interval=2
      return @final_status if @final_status

      @final_status = self.status
      while ['Queued', 'InProgress'].include?(@final_status[:state])
        sleep poll_interval
        @final_status = self.status
        yield @final_status if block_given?
      end

      raise @final_status[:state_message]  if @final_status[:state] == 'Failed'

      @final_status.merge({
          results: results
        })
    end

    def status
      @connection.query_batch @job_id, @batch_id
    end

    # only needed for query
    def init_result_id
      @result_id = @connection.query_batch_result_id(@job_id, @batch_id)[:result]
    end

    def results
      @connection.query_batch_result_data(@job_id, @batch_id, @result_id)
    end
  end
end