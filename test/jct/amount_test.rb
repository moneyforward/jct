require_relative '../test_helper'

Amount = Jct.const_get(:Amount)

class AmountTest < Minitest::Test
  def test_initialize_failure
    error = assert_raises ArgumentError do
      Amount.new('100')
    end
    assert_equal 'amount data-type must be Integer or Rational', error.message
  end

  def test_initialize
    [
      100,
      Rational(100),
      0,
      Rational(0),
      -100,
      Rational(-100)
    ].each do |amount|
      assert_equal amount, Amount.new(amount).value
    end
  end

  def test_per_day_failure
    amount = Amount.new(100)

    error = assert_raises ArgumentError do
      amount.per_day(1.1)
    end
    assert_equal 'number_of_days data-type must be Integer', error.message

    error = assert_raises ArgumentError do
      amount.per_day(0)
    end
    assert_equal 'number_of_days must be greater than zero', error.message
  end

  def test_per_day
    amount = Amount.new(100)

    assert_equal Rational(amount.value, 10), amount.per_day(10)
  end
end
