require_relative '../test_helper'
require 'date'

Term = Jct.const_get(:Term)

class TermTest < Minitest::Test
  DATE20220415 = Date.new(2022, 4, 15)
  DATE20220417 = Date.new(2022, 4, 17)

  def test_initialize_failure
    date_obj = Date.new(2022, 4, 15)
    non_date_obj = '2022/04/15'

    error = assert_raises ArgumentError do
      Term.new(start_on: non_date_obj, end_on: date_obj)
    end
    assert_equal 'start_on data-type must be Date', error.message

    error = assert_raises ArgumentError do
      Term.new(start_on: date_obj, end_on: non_date_obj)
    end
    assert_equal 'end_on data-type must be Date', error.message

    error = assert_raises ArgumentError do
      Term.new(start_on: DATE20220417, end_on: DATE20220415)
    end
    assert_equal 'start_on must not be after than end_on', error.message
  end

  def test_initialize
    Term.new(start_on: DATE20220415, end_on: DATE20220417)
    Term.new(start_on: DATE20220415, end_on: DATE20220415)
  end

  def test_include
    year = 2022
    month = 4
    term = Term.new(
      start_on: Date.new(year, month, 15),
      end_on: Date.new(year, month, 17)
    )

    (15..17).each { |day| assert_equal true, term.includes?(Date.new(year, month, day)) }
    [14, 18].each { |day| assert_equal false, term.includes?(Date.new(year, month, day)) }
  end

  def test_overlaps_with
    term = Term.new(
      start_on: DATE20220415,
      end_on: DATE20220417
    )

    [
      term,
      Term.new(
        start_on: term.start_on,
        end_on: term.end_on - 1
      ),
      Term.new(
        start_on: term.start_on + 1,
        end_on: term.end_on
      ),
      Term.new(
        start_on: term.start_on - 1,
        end_on: term.start_on
      ),
      Term.new(
        start_on: term.end_on,
        end_on: term.end_on + 1
      )
    ].each do |other_term|
      assert_equal(
        true,
        term.overlaps_with?(other_term)
      )
    end

    [
      Term.new(
        start_on: term.start_on - 2,
        end_on: term.start_on - 1
      ),
      Term.new(
        start_on: term.end_on + 1,
        end_on: term.end_on + 2
      )
    ].each do |other_term|
      assert_equal(
        false,
        term.overlaps_with?(other_term)
      )
    end
  end

  def test_number_of_days
    [
      {
        term: Term.new(
          start_on: Date.new(2022, 4, 15),
          end_on: Date.new(2022, 4, 15)
        ),
        expected_value: 1
      },
      {
        term: Term.new(
          start_on: Date.new(2022, 4, 15),
          end_on: Date.new(2022, 4, 16)
        ),
        expected_value: 2
      }
    ].each do |v|
      assert_equal v[:term].number_of_days, v[:expected_value]
    end
  end

  def number_of_days_that_overlap_with
    term = Term.new(
      start_on: DATE20220415,
      end_on: DATE2022041517
    )

    [
      {
        term: term,
        expected_value: 3
      },
      {
        term: Term.new(
          start_on: term.start_on,
          end_on: term.start_on
        ),
        expected_value: 1
      },
      {
        term: Term.new(
          start_on: term.start_on - 1,
          end_on: term.end_on + 1
        ),
        expected_value: 3
      },
      {
        term: Term.new(
          start_on: term.start_on - 1,
          end_on: term.start_on
        ),
        expected_value: 1
      },
      {
        term: Term.new(
          start_on: term.end_on,
          end_on: term.end_on + 1
        ),
        expected_value: 1
      },
      {
        term: Term.new(
          start_on: term.start_on - 2,
          end_on: term.start_on - 1
        ),
        expected_value: 0
      },
      {
        term: Term.new(
          start_on: term.end_on + 1,
          end_on: term.end_on + 2
        ),
        expected_value: 0
      },
    ].each do |v|
      assert_equal(
        term.number_of_days_that_overlap_with(v[:term]),
        v[:expected_value]
      )
    end
  end
end
