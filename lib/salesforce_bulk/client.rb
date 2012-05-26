module SalesforceBulk
  # Interface for operating the Salesforce Bulk REST API
  class Client
    # The host to use for authentication. Defaults to login.salesforce.com
    attr_accessor :host
    
    # The Salesforce password
    attr_accessor :password
    
    # The Salesforce security token
    attr_accessor :token
    
    # The Salesforce username
    attr_accessor :username
    
    # The API version the client is using. Defaults to 23.0
    attr_accessor :version
    
    def initialize(options={})
      self.username = options[:username]
      self.password = options[:password]
      self.token = options[:token]
      
      options.merge!(:host => 'login.salesforce.com', :version => '23.0')
      
      self.host = options[:host]
      self.version = options[:version]
    end
  end
end