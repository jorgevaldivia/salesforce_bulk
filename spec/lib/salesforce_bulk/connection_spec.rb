#encoding: utf-8
require 'spec_helper'

describe SalesforceBulk::Connection do
  let(:subject) { described_class.new nil, nil, nil, nil }

  {
    login: 0,
    create_job: 3,
    close_job: 1,
    query_batch: 2,
    query_batch_result_id: 2,
    query_batch_result_data: 3,

  }.each do |method_name, num_of_params|
    describe "##{method_name}" do
      it 'should delegate correctly to Http class' do
        SalesforceBulk::Http.
          should_receive(method_name).
          and_return({})
        #TODO lookup how to call methods with generic arguments
        subject.send(method_name, *Array.new(num_of_params))
      end
    end
  end

  describe '#add_query' do
    it 'should delegate correctly to Http class' do
      SalesforceBulk::Http.should_receive(:add_batch).
          and_return({})
      subject.add_query(nil, nil)
    end
  end

  describe '#add_batch' do
    it 'should delegate correctly to underlying classes' do
      SalesforceBulk::Http.should_receive(:add_batch).
          and_return({})
      SalesforceBulk::Helper.should_receive(:records_to_csv).
        and_return('My,Awesome,CSV')
      subject.add_batch(nil, 'non emtpy records')
    end

    it 'should return -1 for nil input' do
      return_code = subject.add_batch(nil, nil)
      expect(return_code).to eq(-1)
    end

    it 'should return -1 for empty input' do
      return_code = subject.add_batch(nil, [])
      expect(return_code).to eq(-1)
    end
  end
end