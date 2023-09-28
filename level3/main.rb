require 'json'
require 'date'

CARS = JSON.parse(File.read('./data/input.json'))['cars']
RENTALS = JSON.parse(File.read('./data/input.json'))['rentals']

class Rental
  attr_reader :id, :car, :start_date, :end_date, :distance

  def initialize(rental)
    @id = rental['id']
    @start_date = Date.parse(rental['start_date'])
    @end_date = Date.parse(rental['end_date'])
    @distance = rental['distance']
    @car = CARS.find { |car| car['id'] == rental['car_id'] }
  end

  def duration
    @duration ||= (end_date - start_date).to_i + 1
  end

  def price_per_day
    car['price_per_day']
  end

  def price_per_km
    @car['price_per_km']
  end

  def price_per_distance
    distance * price_per_km
  end

  def price_per_day_with_discount
    price = price_per_day
    duration.times.map do |day|
      next if day.zero?

      price += price_per_day * discount_per_day(day)
    end
    price.to_i
  end

  def discount_per_day(day)
    case day
    when 1..3
      0.9
    when 4..9
      0.7
    else
      0.5
    end
  end

  def total_price
    @total_price ||= calculate_total_price
  end

  def calculate_total_price
    total_price = price_per_distance
    total_price + price_per_day_with_discount
  end

  def process
    {
      id: id,
      price: calculate_total_price,
      commission: Commission.new(self).process
    }
  end
end

class Commission
  attr_reader :rental, :total_commission, :total_price, :duration

  def initialize(rental)
    @total_price = rental.total_price
    @duration = rental.duration
    @total_commission = total_price * 0.3
  end

  def insurance_fee
    total_commission / 2
  end

  def assistance_fee
    duration * 100
  end

  def drivy_fee
    total_commission - insurance_fee - assistance_fee
  end

  def process
    {
      insurance_fee: insurance_fee.to_i,
      assistance_fee: assistance_fee.to_i,
      drivy_fee: drivy_fee.to_i
    }
  end
end

class Main
  attr_reader :cars, :rentals

  def process
    rentals_prices = RENTALS.map do |rental|
      Rental.new(rental).process
    end

    json_data = { rentals: rentals_prices }
    json_string = JSON.pretty_generate(json_data)

    File.write('data/output.json', json_string)

    rentals_prices
  end
end

Main.new.process
