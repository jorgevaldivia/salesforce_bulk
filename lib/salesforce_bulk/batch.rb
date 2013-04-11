module SalesforceBulk
  class Batch
    def initialize connection, job_id, batch_id
      @connection = connection
      @job_id = job_id
      @batch_id = batch_id
    end

    def final_status poll_interval=2
      last_status = self.status
      while ['Queued', 'InProgress'].include?(last_status[:state])
        sleep poll_interval
        last_status = self.status
        yield last_status if block_given?
      end
      last_status
    end

    def status
      @connection.query_batch @job_id, @batch_id
    end
  end
end