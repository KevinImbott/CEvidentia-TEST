require_relative '../src/commission'
require 'JSON'

RSpec.describe Commission do
  let(:fake_rental) do
    double('Rental',
           total_price: 100,
           additional_insurance_price: 10,
           duration: 5)
  end

  let(:commission) { Commission.new(rental: fake_rental) }

  describe '#initialize' do
    it 'sets the instance variables correctly' do
      expect(commission.total_price).to eq(100)
      expect(commission.additional_insurance_price).to eq(10)
      expect(commission.duration).to eq(5)
      expect(commission.total_commission).to eq(30)
    end
  end

  describe '#process' do
    it 'returns an array of actions' do
      expected_actions = [
        { 'who' => 'insurance', 'type' => 'credit', 'amount' => commission.send(:insurance_fee).to_i },
        { 'who' => 'assistance', 'type' => 'credit', 'amount' => commission.send(:assistance_fee).to_i },
        { 'who' => 'drivy', 'type' => 'credit',
          'amount' => (commission.send(:drivy_fee) + commission.additional_insurance_price).to_i }
      ]

      expected_json = JSON.pretty_generate(expected_actions)

      expect(JSON.pretty_generate(commission.process)).to eq(expected_json)
    end
  end
end
