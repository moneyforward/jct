require_relative '../../test_helper'

# 非常に遅いテストなのでファイルを分割している
class Geld::ExciseTest < Minitest::Test
  def test_amount_separated_by_rateに1日から365日の日付を入れた際に分割された結果の合計がamountと等しいこと
    # amountは素数を指定することで、必ず余りが出るようにしている
    Date.new(2019,1,2).upto(Date.new(2019,12,31)).each do |end_on|
      result = Geld::Excise.amount_separated_by_rate(amount: 14321, start_on: Date.new(2019, 1, 1), end_on: end_on)
      assert_equal 14321, result.each_value.reduce(&:+)
    end
  end
end
