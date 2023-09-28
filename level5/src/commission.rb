class Commission
  attr_reader :rental, :total_commission, :total_price, :duration, :additional_insurance_price

  def initialize(rental:)
    @total_price = rental.total_price
    @additional_insurance_price = rental.additional_insurance_price
    @duration = rental.duration
    @total_commission = total_price * 0.3
  end

  def process
    actions
  end

  private

  def actions
    [
      {
        "who": 'insurance',
        "type": 'credit',
        "amount": insurance_fee.to_i
      },
      {
        "who": 'assistance',
        "type": 'credit',
        "amount": assistance_fee.to_i
      },
      {
        "who": 'drivy',
        "type": 'credit',
        "amount": drivy_fee.to_i + additional_insurance_price
      }
    ]
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
end
