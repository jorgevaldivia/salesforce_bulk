#encoding: utf-8
require 'spec_helper'

describe SalesforceBulk::Batch do
  describe '#final_status' do
    it 'should return the final status if it already exists' do
      b = described_class.new nil, nil, nil
      expected_status = {w: :tf}
      b.should_not_receive(:status)
      b.instance_variable_set '@final_status', expected_status
      expect(b.final_status).to eq(expected_status)
    end
  end
end