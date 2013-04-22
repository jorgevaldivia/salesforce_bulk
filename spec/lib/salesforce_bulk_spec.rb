#encoding: utf-8
require 'spec_helper'

describe SalesforceBulk::Api do
  let(:empty_connection) do
    SalesforceBulk::Connection.new(nil, nil, nil, nil)
  end

  #TODO lookup how implicit subject works
  #TODO lookup how forced refresh of let works
  {
    upsert: 3,
    update: 2,
    insert: 2,
    delete: 2,
  }.each do |method_name, num_of_params|
    describe "##{method_name}" do
      it 'should delegate to #start_job' do
        SalesforceBulk::Connection.
          should_receive(:connect).
          and_return(empty_connection)
        s = described_class.new(nil, nil)
        s.should_receive(:start_job).
          with(method_name.to_s, *Array.new(num_of_params))
        s.send(method_name, *Array.new(num_of_params))
      end

      it 'should trigger correct workflow' do
        SalesforceBulk::Connection.
          should_receive(:connect).
          and_return(empty_connection)
        s = described_class.new(nil, nil)
        # TODO lookup how to chain receiver
        empty_connection.should_receive(:create_job).ordered
        empty_connection.should_receive(:add_batch).ordered
        empty_connection.should_receive(:close_job).ordered
        res = s.send(method_name, *Array.new(num_of_params))
        expect(res).to be_a(SalesforceBulk::Batch)
      end
    end
  end

  describe '#query' do
    it 'should trigger correct workflow' do
      pending 'investigation necessary'
      SalesforceBulk::Connection.
          should_receive(:connect).
          and_return(empty_connection)
      s = described_class.new(nil, nil)
      sobject_input = 'sobject_stub'
      query_input = 'query_stub'
      # TODO lookup how to partial check with should_receive with
      empty_connection.should_receive(:add_query).ordered.
        and_return(123)
      empty_connection.should_receive(:close_job).ordered
      s.query(sobject_input, query_input)
    end
  end
end