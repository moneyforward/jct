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

require_relative '../../test_helper'

class JctTest < Minitest::Test
  def test_amount_separated_by_rateに該当する消費税が1つとなる期間と、60万1から80万までのamountを入れた際に分割された結果の合計がamountと等しいこと
    600_001.upto(800_000).each do |amount|
      result = Jct.amount_separated_by_rate(amount: amount, start_on: Date.new(2020, 1, 1), end_on: Date.new(2020, 2, 29))
      assert_equal amount, result.each_value.reduce(&:+)
    end
  end

  def test_amount_separated_by_rateに該当する消費税が2つとなる期間と、60万1から80万までのamountを入れた際に分割された結果の合計がamountと等しいこと
    600_001.upto(800_000).each do |amount|
      result = Jct.amount_separated_by_rate(amount: amount, start_on: Date.new(2019, 1, 1), end_on: Date.new(2019, 12, 31))
      assert_equal amount, result.each_value.reduce(&:+)
    end
  end

  def test_amount_separated_by_rateに該当する消費税が3つとなる期間と、60万1から80万までのamountを入れた際に分割された結果の合計がamountと等しいこと
    600_001.upto(800_000).each do |amount|
      result = Jct.amount_separated_by_rate(amount: amount, start_on: Date.new(1997, 1, 1), end_on: Date.new(2019, 12, 31))
      assert_equal amount, result.each_value.reduce(&:+)
    end
  end

  def test_amount_separated_by_rateに該当する消費税が4つとなる期間と、60万1から80万までのamountを入れた際に分割された結果の合計がamountと等しいこと
    600_001.upto(800_000).each do |amount|
      result = Jct.amount_separated_by_rate(amount: amount, start_on: Date.new(1989, 1, 1), end_on: Date.new(2019, 12, 31))
      assert_equal amount, result.each_value.reduce(&:+)
    end
  end

  def test_amount_separated_by_rateに該当する消費税が5つとなる期間と、60万1から80万までのamountを入れた際に分割された結果の合計がamountと等しいこと
    600_001.upto(800_000).each do |amount|
      result = Jct.amount_separated_by_rate(amount: amount, start_on: Date.new(1900, 8, 1), end_on: Date.new(2019, 12, 31))
      assert_equal amount, result.each_value.reduce(&:+)
    end
  end
end
