require_relative '../../test_helper'

class Geld::ExciseTest < Minitest::Test
  def test_amount_separated_by_rateに該当する消費税が1つとなる期間と、40万1から60万までのamountを入れた際に分割された結果の合計がamountと等しいこと
    400_001.upto(600_000).each do |amount|
      result = Geld::Excise.amount_separated_by_rate(amount: amount, start_on: Date.new(2020, 1, 1), end_on: Date.new(2020, 2, 29))
      assert_equal amount, result.each_value.reduce(&:+)
    end
  end

  def test_amount_separated_by_rateに該当する消費税が2つとなる期間と、40万1から60万までのamountを入れた際に分割された結果の合計がamountと等しいこと
    400_001.upto(600_000).each do |amount|
      result = Geld::Excise.amount_separated_by_rate(amount: amount, start_on: Date.new(2019, 1, 1), end_on: Date.new(2019, 12, 31))
      assert_equal amount, result.each_value.reduce(&:+)
    end
  end

  def test_amount_separated_by_rateに該当する消費税が3つとなる期間と、40万1から60万までのamountを入れた際に分割された結果の合計がamountと等しいこと
    400_001.upto(600_000).each do |amount|
      result = Geld::Excise.amount_separated_by_rate(amount: amount, start_on: Date.new(1997, 1, 1), end_on: Date.new(2019, 12, 31))
      assert_equal amount, result.each_value.reduce(&:+)
    end
  end

  def test_amount_separated_by_rateに該当する消費税が4つとなる期間と、40万1から60万までのamountを入れた際に分割された結果の合計がamountと等しいこと
    400_001.upto(600_000).each do |amount|
      result = Geld::Excise.amount_separated_by_rate(amount: amount, start_on: Date.new(1989, 1, 1), end_on: Date.new(2019, 12, 31))
      assert_equal amount, result.each_value.reduce(&:+)
    end
  end

  def test_amount_separated_by_rateに該当する消費税が5つとなる期間と、40万1から60万までのamountを入れた際に分割された結果の合計がamountと等しいこと
    400_001.upto(600_000).each do |amount|
      result = Geld::Excise.amount_separated_by_rate(amount: amount, start_on: Date.new(1900, 8, 1), end_on: Date.new(2019, 12, 31))
      assert_equal amount, result.each_value.reduce(&:+)
    end
  end
end
