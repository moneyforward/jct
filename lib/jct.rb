require 'date'
require 'bigdecimal'
require 'bigdecimal/util'
require 'jct/excise_tax_rate'
require 'jct/term'
require 'jct/amount'
require 'jct/version'

module Jct
  extend self

  RATE100 = 1r.freeze
  RATE103 = 1.03r.freeze
  RATE105 = 1.05r.freeze
  RATE108 = 1.08r.freeze
  RATE110 = 1.10r.freeze
  EXCISE_TAX_RATES = [
    # 1873/1/1 is the date when Japan changed its calendar to the solar calendar (Meiji era).
    ExciseTaxRate.new(rate: RATE100, term: Term.new(start_on: Date.new(1873, 1, 1), end_on: Date.new(1989, 3, 31))),
    ExciseTaxRate.new(rate: RATE103, term: Term.new(start_on: Date.new(1989, 4, 1), end_on: Date.new(1997, 3, 31))),
    ExciseTaxRate.new(rate: RATE105, term: Term.new(start_on: Date.new(1997, 4, 1), end_on: Date.new(2014, 3, 31))),
    ExciseTaxRate.new(rate: RATE108, term: Term.new(start_on: Date.new(2014, 4, 1), end_on: Date.new(2019, 9, 30))),
    # If we were to use Date::Infinity.new for end_on, an exception would occur in the later calculation,
    # so here we will use a date far in the future.
    ExciseTaxRate.new(rate: RATE110, term: Term.new(start_on: Date.new(2019, 10, 1), end_on: Date.new(2999, 1, 1)))
  ]

  private_constant :EXCISE_TAX_RATES, :ExciseTaxRate, :Term, :Amount

  def amount_with_tax(amount, date: Date.today, fraction: :truncate)
    return amount if amount < 0

    (BigDecimal(amount.to_s) * rate(date)).__send__(fraction)
  end

  def yearly_amount_with_tax(amount:, start_on:, end_on:, fraction: :truncate)
    amount = Amount.new(amount)
    return amount.value if amount.value < 0

    term = Term.new(start_on: start_on, end_on: end_on)

    EXCISE_TAX_RATES.inject(0) do |sum, excise_tax_rate|
      sum + (
        amount.per_day(term.number_of_days) *
        term.number_of_days_that_overlap_with(excise_tax_rate.term) *
        excise_tax_rate.rate
      ).__send__(fraction)
    end
  end

  # Takes the amount and period and returns a HASH with the amount divided by the sales tax period.
  # e.g. 1000, Date.new(1997, 3, 31), Date.new(1997, 4, 9)
  # => { Jct::RATE103 => 100, Jct::RATE105 => 900 }
  #
  # MEMO: This method does not perform sales tax calculations
  # For example, if there is an amount to which the 8% tax rate applies and an amount to which the 10% tax rate applies,
  # and there are other charges that should be combined (e.g., the annual basic fee and the optional fee),
  # if this method returns the amount including tax, it cannot be combined with the other charges.
  def amount_separated_by_rate(amount:, start_on:, end_on:)
    amount = Amount.new(amount)
    raise ArgumentError.new('amount must be greater than or equal to zero') if amount.value < 0

    term = Term.new(start_on: start_on, end_on: end_on)
    raise ArgumentError.new('start_on must bigger than 1873/1/1') if start_on < EXCISE_TAX_RATES.first.term.start_on

    {}.tap do |return_hash|
      EXCISE_TAX_RATES.each do |excise_tax_rate|
        next unless excise_tax_rate.is_in_effect_for?(term)

        return_hash[excise_tax_rate.rate] = (
          amount.per_day(term.number_of_days) *
          term.number_of_days_that_overlap_with(excise_tax_rate.term)
        ).truncate
      end

      # If the divided amount is not divisible by the number of target tax rates,
      # the sum of the amount in the argument and the divided amount may be less than the actual value.
      # This is because the undivided value is truncated at the time of division.
      # e.g.
      #    amount: 100000, start_on: 1997/3/31, end_on 2014/4/1
      #    3%:16
      #    5%:99_967
      #    8%:16
      #    => 16+99967+16=99999
      # Add the amount that is out of alignment to the amount that belongs to the lowest sales tax amount
      # to equal the sum of the argument amount and the divided amount.
      # The reason for adding the shortfall to the amount that belongs to the least amount of consumption tax
      # is so that the user will have an advantage when the consumption tax is calculated based on this amount.
      # Example 1
      #    amount: 100000, start_on: 1997/3/31, end_on 2014/4/1
      #    3%:17 <- Actually 16, but add 1 yen.
      #    5%:99_967
      #    8%:16
      #    => 17+99967+16=100000
      #
      # Example 2:
      #    amount: 100000, start_on: 2014/3/31, end_on 2019/10/1
      #    5%:51 <- Actually 49, but add 2 yen.
      #    8%:99_900
      #    10%:49
      #    => 51+99900+49=100000
      #
      # FIXME: `Enumerable#sum` has been supported since ruby 2.4, but this gem uses `reduce` because it still needs to support ruby 2.3 series.
      summarize_separated_amount = return_hash.each_value.reduce(&:+)
      if amount.value != summarize_separated_amount
        return_hash[return_hash.each_key.min] += (amount.value - summarize_separated_amount)
      end
    end
  end

  def rate(date = Date.today)
    EXCISE_TAX_RATES.find {
      |excise_tax_rate| excise_tax_rate.is_in_effect_on?(date)
    }.rate || RATE100
  end
end
