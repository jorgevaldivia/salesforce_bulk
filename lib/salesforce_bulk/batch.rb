module SalesforceBulk
  class Batch
    attr_reader :connection
    attr_reader :batch_id
    attr_reader :job_id

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
      response = SalesforceBulk::Http.query_batch(
        @connection.instance,
        @connection.session_id,
        @job_id,
        @batch_id,
        @connection.api_version,
        )
      puts response.inspect
      response
    end
  end
end