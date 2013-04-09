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
      while ['Queued', 'InProgress'].include?(last_status.name)
        sleep poll_interval
        last_status = self.status
      end
      last_status
    end

    def status
      response = @connection.get_request(
        nil,
        "job/#{@job_id}/batch/#{@batch_id}",
        {})
      puts "the response: #{response.inspect}"
      SalesforceBulk::JobStatus.parse response
    end
  end
end