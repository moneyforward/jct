module Jct
  class Amount
    attr_reader :value

    def initialize(amount)
      # You can convert Integer/BigDecimal/Float/String/Rational classes to Rational,
      # but the `amount` does not accept BigDeciaml, Float and String for the following reasons.
      #   - Rational objects may be implicitly converted to BigDecimal type when performing arithmetic operations using BigDecimal and Rational.
      #     - Also, when you try to convert BigDecimal to Rational, the resulting value may not be Rational, but BigDecimal.
      #   - Float is not accepted because it is not suitable for calculating sales tax rates.
      #   - String is not accepted because an exception is raised by data that cannot be converted, such as 1.1.1, for example.
      raise ArgumentError.new('amount data-type must be Integer or Rational') unless amount.is_a?(Integer) || amount.is_a?(Rational)

      @value = amount
    end

    def per_day(number_of_days)
      raise ArgumentError.new('number_of_days data-type must be Integer') unless number_of_days.is_a?(Integer)
      raise ArgumentError.new('number_of_days must be greater than zero') if number_of_days <= 0

      Rational(value, number_of_days)
    end
  end
end
