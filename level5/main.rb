require 'json'
require 'date'

DATA = JSON.parse(File.read('./data/input.json'))
CARS = DATA['cars']
RENTALS = DATA['rentals']
OPTIONS = DATA['options']

require_relative './src/rental'

class Main
  attr_reader :cars, :rentals

  def process
    rentals = RENTALS.map do |rental|
      Rental.new(json_rental: rental).process
    end

    json_string = JSON.pretty_generate(rentals: rentals)

    File.write('data/output.json', json_string)

    rentals
  end
end

Main.new.process
