require_relative '../test_helper'
require 'date'

ExciseTaxRate = Jct.const_get(:ExciseTaxRate)
Term = Jct.const_get(:Term)


class ExciseTaxRateTest < Minitest::Test
  EXCISE_TAX_RATE108 = ExciseTaxRate.new(
    rate: 1.08r,
    term: Term.new(
      start_on: Date.new(2014, 4, 1),
      end_on: Date.new(2019, 9, 30)
    )
  )

  def test_is_in_effect_on
    [
      EXCISE_TAX_RATE108.term.start_on,
      EXCISE_TAX_RATE108.term.start_on + 1,
      EXCISE_TAX_RATE108.term.end_on - 1,
      EXCISE_TAX_RATE108.term.end_on,
    ].each do |date|
      assert_equal true, EXCISE_TAX_RATE108.is_in_effect_on?(date)
    end

    [
      EXCISE_TAX_RATE108.term.start_on - 1,
      EXCISE_TAX_RATE108.term.end_on + 1
    ].each do |date|
      assert_equal false, EXCISE_TAX_RATE108.is_in_effect_on?(date)
    end
  end

  def test_is_in_effect_for
    [
      EXCISE_TAX_RATE108.term,
      Term.new(
        start_on: EXCISE_TAX_RATE108.term.start_on,
        end_on: EXCISE_TAX_RATE108.term.end_on - 1
      ),
      Term.new(
        start_on: EXCISE_TAX_RATE108.term.start_on + 1,
        end_on: EXCISE_TAX_RATE108.term.end_on
      ),
      Term.new(
        start_on: EXCISE_TAX_RATE108.term.start_on - 1,
        end_on: EXCISE_TAX_RATE108.term.start_on
      ),
      Term.new(
        start_on: EXCISE_TAX_RATE108.term.end_on,
        end_on: EXCISE_TAX_RATE108.term.end_on + 1
      )
    ].each do |term|
      assert_equal(
        true,
        EXCISE_TAX_RATE108.is_in_effect_for?(term)
      )
    end

    [
      Term.new(
        start_on: EXCISE_TAX_RATE108.term.start_on - 2,
        end_on: EXCISE_TAX_RATE108.term.start_on - 1
      ),
      Term.new(
        start_on: EXCISE_TAX_RATE108.term.end_on + 1,
        end_on: EXCISE_TAX_RATE108.term.end_on + 2
      )
    ].each do |term|
      assert_equal(
        false,
        EXCISE_TAX_RATE108.is_in_effect_for?(term)
      )
    end
  end
end
