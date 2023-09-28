require_relative '../src/rental'
require_relative '../main'

require 'JSON'

RSpec.describe Rental do
  let(:fake_json_rental) do
    {
      'id' => 1,
      'car_id' => 1,
      'start_date' => '2023-09-01',
      'end_date' => '2023-09-05',
      'distance' => 100
    }
  end

  let(:fake_car) do
    {
      'id' => 1,
      'price_per_day' => 100,
      'price_per_km' => 10
    }
  end

  let(:fake_options) do
    [
      { 'rental_id' => 1, 'type' => 'gps' },
      { 'rental_id' => 1, 'type' => 'baby_seat' }
    ]
  end

  let(:rental) { Rental.new(json_rental: fake_json_rental) }

  before do
    allow(CARS).to receive(:find).and_return(fake_car)
    allow(OPTIONS).to receive(:select).and_return(fake_options)
  end

  describe '#initialize' do
    it 'sets the instance variables correctly' do
      expect(rental.car).to eq(fake_car)
      expect(rental.options).to eq(%w[gps baby_seat])
    end
  end

  describe '#process' do
    it 'returns a hash of id, options, and actions' do
      expected_result = {
        id: 1,
        options: %w[gps baby_seat],
        actions: rental.send(:actions)
      }

      expect(rental.process).to eq(expected_result)
    end
  end

  describe '#total_price' do
    it 'calculates the total price correctly' do
      expected_price = 1400
      allow(rental).to receive(:calculate_total_price).and_return(expected_price)

      expect(rental.total_price).to eq(expected_price)
    end
  end

  describe '#additional_insurance_price' do
    context 'when additional insurance option is present' do
      it 'returns the correct price' do
        rental.options << 'additional_insurance'
        expected_price = rental.duration * 1000

        expect(rental.additional_insurance_price).to eq(expected_price)
      end
    end

    context 'when additional insurance option is not present' do
      it 'returns zero' do
        rental.options.delete('additional_insurance')

        expect(rental.additional_insurance_price).to eq(0)
      end
    end
  end

  # Add more test cases for other methods as needed

  private

  # Stub the constant values used in the class
  let(:CARS) { [fake_car] }
  let(:OPTIONS) { fake_options }
end
