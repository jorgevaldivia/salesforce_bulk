module SalesforceBulk
  class Connection
    attr_reader :instance
    attr_reader :session_id
    attr_reader :api_version

    def initialize(username, password, api_version, sandbox)
      @username = username
      @password = password
      @api_version = api_version
      @sandbox = sandbox
      login
    end

    def login
      response = SalesforceBulk::Http.login(
        @sandbox,
        @username,
        @password,
        @api_version)

      @session_id = response[:session_id]
      @instance = response[:instance]
    end

    def create_job operation, sobject, external_field
      SalesforceBulk::Http.create_job(
        @instance,
        @session_id,
        operation,
        sobject,
        @api_version,
        external_field)[:id]
    end

    def close_job job_id
      SalesforceBulk::Http.close_job(
        @instance,
        @session_id,
        job_id,
        @api_version)[:id]
    end

    def add_batch job_id, records
      keys = records.first.keys

      rows = keys.to_csv
      records.each do |r|
        fields = []
        keys.each do |k|
          fields.push(r[k])
        end
        rows << fields.to_csv
      end

      SalesforceBulk::Http.add_batch(
        @instance,
        @session_id,
        job_id,
        rows,
        @api_version)[:id]
    end
  end
end