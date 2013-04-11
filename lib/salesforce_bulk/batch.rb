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
        yield last_status if block_given?
      end
      result_id_cache = result_id
      @final_status.merge({
          result_id: result_id_cache,
          result_data: result_data(result_id_cache),
        })
    end

    def status
      @connection.query_batch @job_id, @batch_id
    end

    def result_id
      @connection.query_batch_result_id(@job_id, @batch_id)[:result]
    end

    def result_data result_id
      @connection.query_batch_result_data(@job_id, @batch_id, result_id)
    end
  end
end