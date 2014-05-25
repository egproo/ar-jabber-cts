require 'spec_helper'

describe MoneyTransfer do
  describe 'for_single_contract' do
    it 'should create a payment' do
      expect(MoneyTransfer.for_single_contract(Room.new).payments.size).to eq 1
    end
  end
end
