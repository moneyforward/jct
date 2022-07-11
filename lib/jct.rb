# Copyright 2022 Money Forward, Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

require 'date'
require 'bigdecimal'
require 'bigdecimal/util'
require 'jct/version'

module Jct
  extend self

  RATE100 = 1r.freeze
  RATE103 = 1.03r.freeze
  RATE105 = 1.05r.freeze
  RATE108 = 1.08r.freeze
  RATE110 = 1.10r.freeze
  EXCISE_HASHES = [
    # 1873/1/1 is the date when Japan changed its calendar to the solar calendar (Meiji era).
    { rate: RATE100, start_on: Date.new(1873, 1, 1), end_on: Date.new(1989, 3, 31) },
    { rate: RATE103, start_on: Date.new(1989, 4, 1), end_on: Date.new(1997, 3, 31) },
    { rate: RATE105, start_on: Date.new(1997, 4, 1), end_on: Date.new(2014, 3, 31) },
    { rate: RATE108, start_on: Date.new(2014, 4, 1), end_on: Date.new(2019, 9, 30) },
    # If we were to use Date::Infinity.new for end_on, an exception would occur in the later calculation, 
    # so here we will use a date far in the future.
    { rate: RATE110, start_on: Date.new(2019, 10, 1), end_on: Date.new(2999, 1, 1) }
  ]

  private_constant :EXCISE_HASHES

  def amount_with_tax(amount, date: Date.today, fraction: :truncate)
    return amount if amount < 0

    (BigDecimal("#{amount}") * rate(date)).__send__(fraction)
  end

  def yearly_amount_with_tax(amount:, start_on:, end_on:, fraction: :truncate)
    # You can convert Integer/BigDecimal/Float/String/Rational classes to Rational,
    # but the `amount` keyword argument does not accept BigDeciaml, Float and String for the following reasons.
    #   - Rational objects may be implicitly converted to BigDecimal type when performing arithmetic operations using BigDecimal and Rational.
    #     - Also, when you try to convert BigDecimal to Rational, the resulting value may not be Rational, but BigDecimal.
    #   - Float is not accepted because it is not suitable for calculating sales tax rates.
    #   - String is not accepted because an exception is raised by data that cannot be converted, such as 1.1.1, for example.
    raise ArgumentError.new('amount data-type must be Integer or Rational') unless amount.is_a?(Integer) || amount.is_a?(Rational)
    raise ArgumentError.new('start_on data-type must be Date') unless start_on.is_a?(Date)
    raise ArgumentError.new('end_on data-type must be Date') unless end_on.is_a?(Date)
    raise ArgumentError.new('start_on must not be after than end_on') if start_on > end_on
    return amount if amount < 0

    daily_amount = Rational(amount, (start_on..end_on).count)

    EXCISE_HASHES.inject(0) do |sum, hash|
      # It determines whether there are overlapping periods by comparing the start and end dates of a certain consumption tax with 
      # the start and end dates of the period for which the tax-inclusive price is to be calculated this time.
      # If there is an overlap, the tax-inclusive price is calculated by multiplying the consumption tax rate for the applicable period
      # by the number of days and pro rata amount for the overlapping period.
      larger_start_on = [start_on, hash[:start_on]].max
      smaller_end_on = [end_on, hash[:end_on]].min

      # Check if there is an overlapping period
      if larger_start_on <= smaller_end_on
        # Number of days of overlapping period
        number_of_days_in_this_excise_rate_term = (larger_start_on..smaller_end_on).count

        sum += (daily_amount * number_of_days_in_this_excise_rate_term * hash[:rate]).__send__(fraction)
      end

      sum
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
    # You can convert Integer/BigDecimal/Float/String/Rational classes to Rational,
    # but the `amount` keyword argument does not accept BigDeciaml, Float and String in for the following reasons.
    #   - Rational objects may be implicitly converted to BigDecimal or Float type 
    #     when performing arithmetic operations using BigDecimal and Rational, or Float and Rational.
    #   - String is not accepted because an exception is raised by data that cannot be converted, such as 1.1.1, for example.
    raise ArgumentError.new('amount data-type must be Integer or Rational') unless amount.is_a?(Integer) || amount.is_a?(Rational)
    raise ArgumentError.new('start_on data-type must be Date') unless start_on.is_a?(Date)
    raise ArgumentError.new('end_on data-type must be Date') unless end_on.is_a?(Date)

    # By using the modified Julian date, we can handle all Date as Integer. This speeds up the process.
    start_on_mjd = start_on.mjd
    end_on_mjd = end_on.mjd

    raise ArgumentError.new('start_on must not be after than end_on') if start_on_mjd > end_on_mjd
    raise ArgumentError.new('start_on must bigger than 1873/1/1') if start_on_mjd < EXCISE_HASHES.first[:start_on].mjd
    raise ArgumentError.new('amount must be greater than or equal to zero') if amount < 0

    # Use the number of days until end_on_mjd.
    daily_amount = Rational(amount, (start_on_mjd..end_on_mjd).count)

    {}.tap do |return_hash|
      EXCISE_HASHES.inject(0) do |sum, hash|
        # It determines whether there are overlapping periods by comparing the start and end dates of a certain consumption tax with 
        # the start and end dates of the period for which the tax-inclusive price is to be calculated this time.
        # If there is an overlap, the price for the subject period is calculated by multiplying the number of days of the overlapping period
        # by the pro rata amount.
        larger_start_on_mjd = [start_on_mjd, hash[:start_on].mjd].max
        smaller_end_on_mjd = [end_on_mjd, hash[:end_on].mjd].min

        # Check if there is an overlapping period
        if larger_start_on_mjd <= smaller_end_on_mjd
          # Number of days of overlapping period
          number_of_days_in_this_excise_rate_term = (larger_start_on_mjd..smaller_end_on_mjd).count
          return_hash[hash[:rate]] = (daily_amount * number_of_days_in_this_excise_rate_term).truncate
        end
      end

      # If the divided amount is not divisible by the number of target tax rates, 
      # the sum of the amount in the argument and the divided amount may be less than the actual value.
      # This is because the undivided value is truncated at the time of division.
      # e.g.
      #    amount: 100000, start_on: 1997/3/31, end_on 2014/4/1の場合
      #    3%:16
      #    5%:99_967
      #    8%:16
      #    => 16+99967+16=99999
      # Add the amount that is out of alignment to the amount that belongs to the lowest sales tax amount
      # to equal the sum of the argument amount and the divided amount.
      # The reason for adding the shortfall to the amount that belongs to the least amount of consumption tax 
      # is so that the user will have an advantage when the consumption tax is calculated based on this amount.
      # Example 1
      #    amount: 100000, start_on: 1997/3/31, end_on 2014/4/1の場合
      #    3%:17 <- Actually 16, but add 1 yen.
      #    5%:99_967
      #    8%:16
      #    => 17+99967+16=100000
      #
      # Example 2:
      #    amount: 100000, start_on: 2014/3/31, end_on 2019/10/1の場合
      #    5%:51 <- Actually 49, but add 2 yen.
      #    8%:99_900
      #    10%:49
      #    => 51+99900+49=100000
      #
      # FIXME: `Enumerable#sum` has been supported since ruby 2.4, but this gem uses `reduce` because it still needs to support ruby 2.3 series.
      summarize_separated_amount = return_hash.each_value.reduce(&:+)
      if amount != summarize_separated_amount
        return_hash[return_hash.each_key.min] += (amount - summarize_separated_amount)
      end
    end
  end

  def rate(date = Date.today)
    case date
    when Date.new(1989, 4, 1)..Date.new(1997, 3, 31)
      RATE103
    when Date.new(1997, 4, 1)..Date.new(2014, 3, 31)
      RATE105
    when Date.new(2014, 4, 1)..Date.new(2019, 9, 30)
      RATE108
    when Date.new(2019, 10, 1)..Date::Infinity.new
      RATE110
    else
      RATE100
    end
  end
end
