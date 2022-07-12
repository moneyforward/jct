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

require_relative '../test_helper'

class JctTest < Minitest::Test
  def assert_bigdecimal_equal(e, v, msg=nil)
    assert_equal(BigDecimal, v.class, msg)
    assert_equal(e, v, msg)
  end

  def test_amount_with_tax
    today = Date.new(1989, 3, 31)

    assert_equal 100,
                 Jct.amount_with_tax(100, date: today)
    assert_equal 1800,
                 Jct.amount_with_tax(1800, date: today)
    assert_equal(-1800, Jct.amount_with_tax(-1800, date: today))

    today = Date.new(1989, 4, 1)

    assert_equal 103,
                 Jct.amount_with_tax(100, date: today)
    assert_equal 1854,
                 Jct.amount_with_tax(1800, date: today)
    assert_equal(-1800, Jct.amount_with_tax(-1800, date: today))

    today = Date.new(1997, 3, 31)

    assert_equal 103,
                 Jct.amount_with_tax(100, date: today)
    assert_equal 1854,
                 Jct.amount_with_tax(1800, date: today)
    assert_equal(-1800, Jct.amount_with_tax(-1800, date: today))

    today = Date.new(1997, 4, 1)

    assert_equal 105,
                 Jct.amount_with_tax(100, date: today)
    assert_equal 1890,
                 Jct.amount_with_tax(1800, date: today)
    assert_equal(-1800, Jct.amount_with_tax(-1800, date: today))

    today = Date.new(2014, 3, 31)

    assert_equal 105,
                 Jct.amount_with_tax(100, date: today)
    assert_equal 1890,
                 Jct.amount_with_tax(1800, date: today)
    assert_equal(-1800, Jct.amount_with_tax(-1800, date: today))
    assert_equal BigDecimal("1_050_000_000_000_000"),
                 Jct.amount_with_tax(BigDecimal("1_000_000_000_000_000"), date: today)

    today = Date.new(2014, 4, 1)

    assert_equal 108,
                 Jct.amount_with_tax(100, date: today)
    assert_equal 1944,
                 Jct.amount_with_tax(1800, date: today)
    assert_equal(-1800, Jct.amount_with_tax(-1800, date: today))
    assert_equal BigDecimal("1_080_000_000_000_000"),
                 Jct.amount_with_tax(BigDecimal("1_000_000_000_000_000"), date: today)

    today = Date.new(2019, 9, 30)

    assert_equal 108,
                 Jct.amount_with_tax(100, date: today)
    assert_equal 1944,
                 Jct.amount_with_tax(1800, date: today)
    assert_equal(-1800, Jct.amount_with_tax(-1800, date: today))
    assert_equal BigDecimal("1_080_000_000_000_000"),
                 Jct.amount_with_tax(BigDecimal("1_000_000_000_000_000"), date: today)

    today = Date.new(2019, 10, 1)

    assert_equal 110,
                 Jct.amount_with_tax(100, date: today)
    assert_equal(-1800, Jct.amount_with_tax(-1800, date: today))
    assert_equal BigDecimal("1_100_000_000_000_000"),
                 Jct.amount_with_tax(BigDecimal("1_000_000_000_000_000"), date: today)
  end

  def test_amount_with_tax_concering_fraction
    today = Date.new(2014, 4, 1)

    [
      [0, 0], [1, 1], [2, 2], [3, 3], [4, 4],
      [5, 5], [6, 6], [7, 7], [8, 8], [9, 9],
      [10, 10], [11, 11], [12, 12], [13, 14], [14, 15],
      [15, 16], [16, 17], [17, 18], [18, 19], [19, 20],
      [20, 21]
    ].each do |(amount, expected)|
      assert_equal expected, Jct.amount_with_tax(amount, date: today)
    end
  end

  def test_amount_with_tax_concering_fraction_option
    today = Date.new(2014, 4, 1)

    assert_equal 1078,
                 Jct.amount_with_tax(999, date: today, fraction: :floor)
    assert_equal 1079,
                 Jct.amount_with_tax(999, date: today, fraction: :ceil)
    assert_equal 1078,
                 Jct.amount_with_tax(999, date: today, fraction: :truncate)
  end

  def test_yearly_amount_with_tax_failure
    assert_raises ArgumentError do
      Jct.yearly_amount_with_tax
    end

    assert_raises ArgumentError do
      Jct.yearly_amount_with_tax(amount: 100)
    end

    assert_raises ArgumentError do
      Jct.yearly_amount_with_tax(amount: 100, start_on: Date.new)
    end

    assert_raises ArgumentError do
      Jct.yearly_amount_with_tax(amount: 100, end_on: Date.new)
    end

    error = assert_raises ArgumentError do
      Jct.yearly_amount_with_tax(amount: Date.new, start_on: Date.new(2019, 1, 1), end_on: Date.new(2019, 12, 31))
    end

    assert_equal 'amount data-type must be Integer or Rational', error.message

    error = assert_raises ArgumentError do
      Jct.yearly_amount_with_tax(amount: BigDecimal('100.11'), start_on: Date.new(2019, 1, 1), end_on: Date.new(2019, 12, 31))
    end

    error = assert_raises ArgumentError do
      Jct.yearly_amount_with_tax(amount: 100.11, start_on: Date.new(2019, 1, 1), end_on: Date.new(2019, 12, 31))
    end

    assert_equal 'amount data-type must be Integer or Rational', error.message

    error = assert_raises ArgumentError do
      Jct.yearly_amount_with_tax(amount: '100', start_on: Date.new(2019, 1, 1), end_on: Date.new(2019, 12, 31))
    end

    assert_equal 'amount data-type must be Integer or Rational', error.message

    error = assert_raises ArgumentError do
      Jct.yearly_amount_with_tax(amount: 100, start_on: Time.new(2019, 1, 1), end_on: Date.new(2019, 12, 31))
    end

    assert_equal 'start_on data-type must be Date', error.message

    error = assert_raises ArgumentError do
      Jct.yearly_amount_with_tax(amount: 100, start_on: Date.new(2019, 1, 1), end_on: Time.new(2019, 12, 31))
    end

    assert_equal 'end_on data-type must be Date', error.message

    error = assert_raises ArgumentError do
      Jct.yearly_amount_with_tax(amount: 100, start_on: Date.new(2019, 1, 1), end_on: Date.new(2018, 12, 1))
    end

    assert_equal 'start_on must not be after than end_on', error.message
  end

  def test_yearly_amount_with_tax
    [
      [0,      Date.new(1989, 4, 1),  Date.new(1989, 4, 1),   0],       # amountが0の時
      [-100,   Date.new(1989, 4, 1),  Date.new(1989, 4, 1),   -100],    # amountが負数の時
      [Rational(100), Date.new(1989, 4, 1), Date.new(1989, 4, 1), 103], # amountがRational型の時
      [100,    Date.new(1989, 4, 1),  Date.new(1989, 4, 1),   103],     # 消費税率3%時に1日分を計算する
      [100,    Date.new(1997, 4, 1),  Date.new(1997, 4, 1),   105],     # 消費税率5%時に1日分を計算する
      [100,    Date.new(2014, 4, 1),  Date.new(2014, 4, 1),   108],     # 消費税率8%時に1日分を計算する
      [100,    Date.new(2019, 10, 1), Date.new(2019, 10, 1),  110],     # 消費税率10%時に1日分を計算する
      [1000,   Date.new(1989, 4, 1),  Date.new(1989, 4, 10),  1030],    # 消費税率3%時に10日分を計算する
      [1000,   Date.new(1997, 4, 1),  Date.new(1997, 4, 10),  1050],    # 消費税率5%時に10日分を計算する
      [1000,   Date.new(2014, 4, 1),  Date.new(2014, 4, 10),  1080],    # 消費税率8%時に10日分を計算する
      [1000,   Date.new(2019, 10, 1), Date.new(2019, 10, 10), 1100],    # 消費税率10%時に10日分を計算する
      [1000,   Date.new(1997, 3, 31), Date.new(1997, 4, 9),   1048],    # 消費税率3, 5%の混合計算
      [1000,   Date.new(2014, 3, 31), Date.new(2014, 4, 9),   1077],    # 消費税率5, 8%の混合計算
      [1000,   Date.new(2019, 9, 30), Date.new(2019, 10, 9),  1098],    # 消費税率8, 10%の混合計算
      [100000, Date.new(1997, 3, 31), Date.new(2014, 4, 1),   104999],  # 消費税率3, 5, 8%の時の混合計算
      [100000, Date.new(1997, 3, 31), Date.new(2019, 10, 1),  105732],  # 消費税率3, 5, 8, 10%の時の混合計算
      [100000, Date.new(2014, 3, 31), Date.new(2019, 10, 1),  107998],  # 消費税率5, 8, 10%の時の混合計算

      # 指定の年間期間の税率が単一だった場合
      [8800,   Date.new(2015, 4, 1),  Date.new(2016, 3, 30), 9504],  # 消費税率8%時に365日分を計算する(金額は会計の個人ベーシック)
      [17200,  Date.new(2015, 4, 1),  Date.new(2016, 3, 30), 18576], # 消費税率8%時に365日分を計算する(金額は会計の個人電話サポート付きベーシック)
      [8800,   Date.new(2015, 4, 1),  Date.new(2016, 3, 31), 9504],  # 消費税率8%時に366日分を計算する(金額は会計の個人ベーシック)
      [17200,  Date.new(2015, 4, 1),  Date.new(2016, 3, 31), 18576], # 消費税率8%時に366日分を計算する(金額は会計の個人電話サポート付きベーシック)
      # 指定の年間期間の税率が複数の場合
      [17200,  Date.new(2018, 12, 13), Date.new(2019, 12, 12),  18644], # 消費税率8, 10%時に365日分を計算する

      # 年額計算メソッドを使用して初めて会計の課金処理を行う2019/02/01のデータを想定したテスト
      [8800,   Date.new(2019, 1, 2),  Date.new(2020, 1, 1), 9548],  # 365日分を計算(金額は会計の個人ベーシック)
      [17200,  Date.new(2019, 1, 2),  Date.new(2020, 1, 1), 18662], # 365日分を計算(金額は会計の個人電話サポート付きベーシック)
      [21780,  Date.new(2019, 1, 2),  Date.new(2020, 1, 1), 23633], # 365日分を計算(金額は会計の法人ライト)
      [32780,  Date.new(2019, 1, 2),  Date.new(2020, 1, 1), 35569], # 365日分を計算(金額は会計の法人ベーシック)
      [8800,   Date.new(2019, 1, 2),  Date.new(2020, 1, 2), 9549],  # 366日分を計算(金額は会計の個人ベーシック)
      [17200,  Date.new(2019, 1, 2),  Date.new(2020, 1, 2), 18664], # 366日分を計算(金額は会計の個人電話サポート付きベーシック)
      [21780,  Date.new(2019, 1, 2),  Date.new(2020, 1, 2), 23634], # 366日分を計算(金額は会計の法人ライト)
      [32780,  Date.new(2019, 1, 2),  Date.new(2020, 1, 2), 35569]  # 366日分を計算(金額は会計の法人ベーシック)
    ].each do |amount, start_on, end_on, expected_value|
      assert_equal expected_value, Jct.yearly_amount_with_tax(amount: amount, start_on: start_on, end_on: end_on)
    end
  end

  def test_yearly_amount_with_tax_concering_fraction_option
    start_on = Date.new(2019, 1, 1)
    end_on = Date.new(2019, 12, 31)

    assert_equal 10849, Jct.yearly_amount_with_tax(amount: 10000, start_on: start_on, end_on: end_on, fraction: :floor)
    assert_equal 10851, Jct.yearly_amount_with_tax(amount: 10000, start_on: start_on, end_on: end_on, fraction: :ceil)
    assert_equal 10849, Jct.yearly_amount_with_tax(amount: 10000, start_on: start_on, end_on: end_on, fraction: :truncate)
  end

  def test_amount_separated_by_rate
    [
      [0,             Date.new(1989, 4, 1),  Date.new(1989, 4, 1),  { Jct::RATE103 => 0 }], # amountが0の時
      [Rational(100), Date.new(1989, 4, 1),  Date.new(1989, 4, 1),  { Jct::RATE103 => 100 }], # amountがRational型の時
      [100,           Date.new(1988, 4, 1),  Date.new(1988, 4, 2),  { Jct::RATE100 => 100 }], # 消費税率0%時に1日分含まれる
      [100,           Date.new(1989, 4, 1),  Date.new(1989, 4, 1),  { Jct::RATE103 => 100 }], # 消費税率3%時に1日分含まれる
      [100,           Date.new(1997, 4, 1),  Date.new(1997, 4, 1),  { Jct::RATE105 => 100 }], # 消費税率5%時に1日分含まれる
      [100,           Date.new(2014, 4, 1),  Date.new(2014, 4, 1),  { Jct::RATE108 => 100 }], # 消費税率8%時に1日分含まれる
      [100,           Date.new(2019, 10, 1), Date.new(2019, 10, 1), { Jct::RATE110 => 100 }], # 消費税率10%時に1日分含まれる

      # 消費税境界値のテスト
      [100000,        Date.new(1989, 3, 30), Date.new(1989, 3, 31),  { Jct::RATE100 => 100_000}], # 0%最後の日
      [100000,        Date.new(1989, 3, 31), Date.new(1989, 4, 1),   { Jct::RATE100 => 50_000, Jct::RATE103 => 50_000}], # 0%->3%の境界値
      [100000,        Date.new(1989, 4, 1), Date.new(1989, 4, 2),    { Jct::RATE103 => 100_000}], # 3%最初の日
      [100000,        Date.new(1997, 3, 30), Date.new(1997, 3, 31),  { Jct::RATE103 => 100_000}], # 3%最後の日
      [100000,        Date.new(1997, 3, 31), Date.new(1997, 4, 1),   { Jct::RATE103 => 50_000, Jct::RATE105 => 50_000}], # 3%->5%の境界値
      [100000,        Date.new(1997, 4, 1), Date.new(1997, 4, 2),    { Jct::RATE105 => 100_000}], # 5%最初の日
      [100000,        Date.new(2014, 3, 30), Date.new(2014, 3, 31),  { Jct::RATE105 => 100_000}], # 5%最初の日
      [100000,        Date.new(2014, 3, 31), Date.new(2014, 4, 1),   { Jct::RATE105 => 50_000, Jct::RATE108 => 50_000}], # 5%->8%
      [100000,        Date.new(2014, 4, 1), Date.new(2014, 4, 2),    { Jct::RATE108 => 100_000}], # 8%最初の日
      [100000,        Date.new(2019, 9, 29), Date.new(2019, 9, 30),  { Jct::RATE108 => 100_000}], # 8%最後の日
      [100000,        Date.new(2019, 9, 30), Date.new(2019, 10, 1),  { Jct::RATE108 => 50_000, Jct::RATE110 => 50_000}], # 8%->10%
      [100000,        Date.new(2019, 10,1), Date.new(2019, 10, 2),   { Jct::RATE110 => 100_000}], # 10%最初の日

      # 期間を跨ぐ場合のテスト
      [1000,          Date.new(1989, 3, 31), Date.new(1989, 4, 9),  { Jct::RATE100 => 100, Jct::RATE103 => 900 }], # 消費税率0, 3%の混合計算
      [1000,          Date.new(1997, 3, 31), Date.new(1997, 4, 9),  { Jct::RATE103 => 100, Jct::RATE105 => 900 }], # 消費税率3, 5%の混合計算
      [1000,          Date.new(2014, 3, 31), Date.new(2014, 4, 9),  { Jct::RATE105 => 100, Jct::RATE108 => 900 }], # 消費税率5, 8%の混合計算
      [1000,          Date.new(2019, 9, 30), Date.new(2019, 10, 9), { Jct::RATE108 => 100, Jct::RATE110 => 900 }], # 消費税率8, 10%の混合計算
      [100000,        Date.new(1997, 3, 31), Date.new(2014, 4, 1),  { Jct::RATE103 => 17, Jct::RATE105 => 99_967, Jct::RATE108 => 16 }], # 消費税率3, 5, 8%の時の混合計算
      [100000,        Date.new(1997, 3, 31), Date.new(2019, 10, 1), { Jct::RATE103 => 13, Jct::RATE105 => 75_535, Jct::RATE108 => 24_440, Jct::RATE110 => 12 }], # 消費税率3, 5, 8, 10%の時の混合計算
      [100000,        Date.new(1988, 3, 31), Date.new(2020, 1, 1), {  Jct::RATE100 => 3_158 , Jct::RATE103 => 25_191, Jct::RATE105 => 53_530, Jct::RATE108 => 17_320, Jct::RATE110 => 801 }], # 消費税率0, 3, 5, 8, 10%の時の混合計算
      [100000,        Date.new(2014, 3, 31), Date.new(2019, 10, 1), { Jct::RATE105 => 51, Jct::RATE108 => 99_900, Jct::RATE110 => 49 }],  # 消費税率5, 8, 10%の時の混合計算

      # 指定の年間期間の税率が単一だった場合
      [8800,   Date.new(2015, 4, 1),  Date.new(2016, 3, 30), { Jct::RATE108 => 8800 }], # 消費税率8%時に365日分
    ].each do |amount, start_on, end_on, expected_value|
      assert_equal expected_value, Jct.amount_separated_by_rate(amount: amount, start_on: start_on, end_on: end_on)
    end
  end

  def test_amount_separated_by_rate_with_failure
    assert_raises ArgumentError do
      Jct.amount_separated_by_rate
    end

    assert_raises ArgumentError do
      Jct.amount_separated_by_rate(amount: 100)
    end

    assert_raises ArgumentError do
      Jct.amount_separated_by_rate(amount: 100, start_on: Date.new)
    end

    assert_raises ArgumentError do
      Jct.amount_separated_by_rate(amount: 100, end_on: Date.new)
    end

    error = assert_raises ArgumentError do
      Jct.amount_separated_by_rate(amount: Date.new, start_on: Date.new(2019, 1, 1), end_on: Date.new(2019, 12, 31))
    end

    assert_equal 'amount data-type must be Integer or Rational', error.message

    error = assert_raises ArgumentError do
      Jct.amount_separated_by_rate(amount: 100.11, start_on: Date.new(2019, 1, 1), end_on: Date.new(2019, 12, 31))
    end

    assert_equal 'amount data-type must be Integer or Rational', error.message

    error = assert_raises ArgumentError do
      Jct.amount_separated_by_rate(amount: '100', start_on: Date.new(2019, 1, 1), end_on: Date.new(2019, 12, 31))
    end

    assert_equal 'amount data-type must be Integer or Rational', error.message

    error = assert_raises ArgumentError do
      Jct.amount_separated_by_rate(amount: 100.to_d, start_on: Date.new(2019, 1, 1), end_on: Date.new(2019, 12, 31))
    end

    assert_equal 'amount data-type must be Integer or Rational', error.message

    error = assert_raises ArgumentError do
      Jct.amount_separated_by_rate(amount: 100, start_on: Time.new(2019, 1, 1), end_on: Date.new(2019, 12, 31))
    end

    assert_equal 'start_on data-type must be Date', error.message

    error = assert_raises ArgumentError do
      Jct.amount_separated_by_rate(amount: 100, start_on: Date.new(2019, 1, 1), end_on: Time.new(2019, 12, 31))
    end

    assert_equal 'end_on data-type must be Date', error.message

    error = assert_raises ArgumentError do
      Jct.amount_separated_by_rate(amount: 100, start_on: Date.new(2019, 1, 1), end_on: Date.new(2018, 12, 1))
    end

    assert_equal 'start_on must not be after than end_on', error.message

    error = assert_raises ArgumentError do
      Jct.amount_separated_by_rate(amount: -100, start_on: Date.new(2018, 1, 1), end_on: Date.new(2018, 12, 1))
    end

    assert_equal 'amount must be greater than or equal to zero', error.message

    error = assert_raises ArgumentError do
      Jct.amount_separated_by_rate(amount: 100, start_on: Date.new(1872, 12, 31), end_on: Date.new(1873, 1, 1))
    end

    assert_equal 'start_on must bigger than 1873/1/1', error.message
  end


  def test_rate
    today = Date.new(1989, 3, 31)
    assert_equal Jct::RATE100, Jct.rate(today)

    today = Date.new(1989, 4, 1)
    assert_equal Jct::RATE103, Jct.rate(today)

    today = Date.new(1997, 3, 31)
    assert_equal Jct::RATE103, Jct.rate(today)

    today = Date.new(1997, 4, 1)
    assert_equal Jct::RATE105, Jct.rate(today)

    today = Date.new(2014, 3, 31)
    assert_equal Jct::RATE105, Jct.rate(today)

    today = Date.new(2014, 4, 1)
    assert_equal Jct::RATE108, Jct.rate(today)

    today = Date.new(2019, 9, 30)
    assert_equal Jct::RATE108, Jct.rate(today)

    today = Date.new(2019, 10, 1)
    assert_equal Jct::RATE110, Jct.rate(today)
  end
end
