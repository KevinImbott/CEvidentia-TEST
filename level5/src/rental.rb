require_relative "./commission"

class Rental
  attr_reader :car, :options, :rental

  def initialize(json_rental:)
    @rental = json_rental
    @car ||= CARS.find { |car| car['id'] == rental['car_id'] }
    @options = OPTIONS.select { |option| option['rental_id'] == id }.map { |option| option['type'] }
  end

  def process
    {
      id: id,
      options: options,
      actions: actions
    }
  end

  def total_price
    @total_price ||= calculate_total_price
  end

  def additional_insurance_price
    additional_insurance? ? duration * 1000 : 0
  end

  def duration
    @duration ||= (end_date - start_date).to_i + 1
  end

  private

  def actions
    [
      {
        "who": 'driver',
        "type": 'debit',
        "amount": total_price.to_i + gps_price + baby_seat_price + additional_insurance_price
      },
      {
        "who": 'owner',
        "type": 'credit',
        "amount": total_price_without_commission.to_i + gps_price + baby_seat_price
      },
      *Commission.new(rental: self).process
    ]
  end

  def id
    @id ||= rental['id']
  end

  def distance
    @distance ||= rental['distance']
  end

  def start_date
    @start_date ||= Date.parse(rental['start_date'])
  end

  def end_date
    @end_date ||= Date.parse(rental['end_date'])
  end

  def price_per_day
    car['price_per_day']
  end

  def price_per_km
    car['price_per_km']
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

  def total_price_without_commission
    @total_price_without_commission ||= total_price * 0.7
  end

  def calculate_total_price
    total_price = price_per_distance
    total_price + price_per_day_with_discount
  end

  def gps_price
    gps? ? duration * 500 : 0
  end

  def baby_seat_price
    baby_seat? ? duration * 200 : 0
  end

  def additional_insurance?
    options.include?('additional_insurance')
  end

  def gps?
    options.include?('gps')
  end

  def baby_seat?
    options.include?('baby_seat')
  end
end
