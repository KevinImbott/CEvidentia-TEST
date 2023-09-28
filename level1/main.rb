require 'json'
require 'date'


class Main
  attr_reader :cars, :rentals

  def initialize
    data = JSON.parse(File.read('./data/input.json'))
    @cars = data['cars']
    @rentals = data['rentals']
  end

  def calculate_price_per_rental(rental)
    car = @cars.find { |car| car['id'] == rental['car_id'] }
    start_date = Date.parse(rental['start_date'])
    end_date = Date.parse(rental['end_date'])
    duration = (end_date - start_date).to_i + 1
    price = rental['distance'] * car['price_per_km']
    price += duration * car['price_per_day']
    price
  end

  def process
    rentals_prices = @rentals.map do |rental|
      price = calculate_price_per_rental(rental)
      { id: rental['id'], price: price }
    end

    json_data = { rentals: rentals_prices }
    json_string = JSON.pretty_generate(json_data)

    File.write('data/output.json', json_string)

    rentals_prices
  end
end

Main.new.process
