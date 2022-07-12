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

# 非常に遅いテストなのでファイルを分割している
class JctTest < Minitest::Test
  def test_amount_separated_by_rateに1日から365日の日付を入れた際に分割された結果の合計がamountと等しいこと
    # amountは素数を指定することで、必ず余りが出るようにしている
    Date.new(2019,1,2).upto(Date.new(2019,12,31)).each do |end_on|
      result = Jct.amount_separated_by_rate(amount: 14321, start_on: Date.new(2019, 1, 1), end_on: end_on)
      assert_equal 14321, result.each_value.reduce(&:+)
    end
  end
end
