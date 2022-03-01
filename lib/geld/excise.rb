require 'date'
require 'bigdecimal'
require 'bigdecimal/util'
require 'geld/excise/version'

module Geld
  module Excise
    extend self

    RATE100 = 1r.freeze
    RATE103 = 1.03r.freeze
    RATE105 = 1.05r.freeze
    RATE108 = 1.08r.freeze
    RATE110 = 1.10r.freeze
    EXCISE_HASHES = [
      { rate: RATE100, start_on: Date.new(1873, 1, 1), end_on: Date.new(1989, 3, 31) }, # 1873/1/1は日本が太陽暦への改暦を行った年(明治改暦)
      { rate: RATE103, start_on: Date.new(1989, 4, 1), end_on: Date.new(1997, 3, 31) },
      { rate: RATE105, start_on: Date.new(1997, 4, 1), end_on: Date.new(2014, 3, 31) },
      { rate: RATE108, start_on: Date.new(2014, 4, 1), end_on: Date.new(2019, 9, 30) },
      # end_onにDate::Infinity.new を使用すると、後の計算で例外が起こるので超未来日の日付を使用する
      { rate: RATE110, start_on: Date.new(2019, 10, 1), end_on: Date.new(2999, 1, 1) }
    ]

    private_constant :EXCISE_HASHES

    def amount_with_tax(amount, date: Date.today, fraction: :truncate)
      return amount if amount < 0

      (BigDecimal("#{amount}") * rate(date)).__send__(fraction)
    end

    # start_on は期間の開始日, end_on は期間の終了日をそれぞれ受け取る
    def yearly_amount_with_tax(amount:, start_on:, end_on:, fraction: :truncate)
      # Integer/BigDecimal/Float/String/Rational classはRationalに変換できるが、下記の理由からamountにBigDeciamlとFloat, Stringは受け付けないこととする
      #   - BigDecimalは、Rationalとの四則演算を行なうとRationalオブジェクトが暗黙的にBigDecimal型に変換されてしまうことがあるため
      #     - またBigDecimalをRationalに変換しようとした際にも変換処理の返り値がRationalでなく、BigDecimalになることがあるため
      #   - Floatはそもそも消費税率計算に向いていないので受け付けない
      #   - Stringの場合は例えば 1.1.1 などの変換できないデータが渡ってくること例外が起きてしまうため受け付けない
      raise ArgumentError.new('amount data-type must be Integer or Rational') unless amount.is_a?(Integer) || amount.is_a?(Rational)
      raise ArgumentError.new('start_on data-type must be Date') unless start_on.is_a?(Date)
      raise ArgumentError.new('end_on data-type must be Date') unless end_on.is_a?(Date)
      raise ArgumentError.new('start_on must not be after than end_on') if start_on > end_on
      return amount if amount < 0

      daily_amount = Rational(amount, (start_on..end_on).count)

      EXCISE_HASHES.inject(0) do |sum, hash|
        # ある消費税の開始日・終了日と、今回税込み価格を算出したい期間の開始日・終了日をそれぞれ比較することで
        # 重複期間があるかどうかを判定している
        # 重複がある場合その重複期間の日数を取得し、対象期間の消費税率と日数、日割り金額をかけて税込み価格を算出する
        larger_start_on = [start_on, hash[:start_on]].max
        smaller_end_on = [end_on, hash[:end_on]].min

        # 重複期間があるかどうか判定している
        if larger_start_on <= smaller_end_on
          # 重複期間の日数を取得する
          number_of_days_in_this_excise_rate_term = (larger_start_on..smaller_end_on).count

          sum += (daily_amount * number_of_days_in_this_excise_rate_term * hash[:rate]).__send__(fraction)
        end

        sum
      end
    end

    # 金額と期間を受け取り、その金額を消費税期間ごとに分割したhashを返却する
    # 例: 1000, Date.new(1997, 3, 31), Date.new(1997, 4, 9)
    # => { Geld::Excise::RATE103 => 100, Geld::Excise::RATE105 => 900 }
    #
    # MEMO: このメソッドでは消費税計算は行わない
    # 例えば、8%の期間の金額と10%の期間の金額があった場合に、他にも合算するべき料金があった場合（基本料金年額とオプション料金など）、
    # このメソッドにて税込金額を返却してしまうと、他の料金との合算ができなくなる。
    def amount_separated_by_rate(amount:, start_on:, end_on:)
      # Integer/BigDecimal/Float/String/Rational classはRationalに変換できるが、下記の理由からamountにBigDeciamlとFloat, Stringは受け付けないこととする
      #   - BigDecimalとFloatは、RationalとFloatの四則演算を行なうとRationalオブジェクトが暗黙的にBigDecimal or Float型に変換されてしまうことがあるため
      #   - Stringの場合は例えば 1.1.1 などの変換できないデータが渡ってくること例外が起きてしまうため受け付けない
      raise ArgumentError.new('amount data-type must be Integer or Rational') unless amount.is_a?(Integer) || amount.is_a?(Rational)
      raise ArgumentError.new('start_on data-type must be Date') unless start_on.is_a?(Date)
      raise ArgumentError.new('end_on data-type must be Date') unless end_on.is_a?(Date)

      #修正ユリウス日を使う事でDateをすべてをIntegerで扱う事が来る為高速化出来る
      start_on_mjd = start_on.mjd
      end_on_mjd = end_on.mjd

      raise ArgumentError.new('start_on must not be after than end_on') if start_on_mjd > end_on_mjd
      raise ArgumentError.new('start_on must bigger than 1873/1/1') if start_on_mjd < EXCISE_HASHES.first[:start_on].mjd
      raise ArgumentError.new('amount must be greater than or equal to zero') if amount < 0

      # これはend_on_mjdを含む日付でカウントしている
      daily_amount = Rational(amount, (start_on_mjd..end_on_mjd).count)

      {}.tap do |return_hash|
        EXCISE_HASHES.inject(0) do |sum, hash|
          # ある消費税の開始日・終了日と、今回税込み価格を算出したい期間の開始日・終了日をそれぞれ比較することで
          # 重複期間があるかどうかを判定している
          # 重複がある場合その重複期間の日数を取得し、日割り金額をかけて対象期間分の価格を算出する
          larger_start_on_mjd = [start_on_mjd, hash[:start_on].mjd].max
          smaller_end_on_mjd = [end_on_mjd, hash[:end_on].mjd].min

          # 重複期間があるかどうか判定している
          if larger_start_on_mjd <= smaller_end_on_mjd
            # 重複期間の日数を取得する
            number_of_days_in_this_excise_rate_term = (larger_start_on_mjd..smaller_end_on_mjd).count
            return_hash[hash[:rate]] = (daily_amount * number_of_days_in_this_excise_rate_term).truncate
          end
        end

        # 分割されたamountが対象となる税率の個数で割り切れない値の場合、
        # 引数に入ってきたamountと分割したamountの合計が少なくなる場合がある。
        # これは分割時に割り切れない値を切り捨てている為である。
        # 例:
        #    amount: 100000, start_on: 1997/3/31, end_on 2014/4/1の場合
        #    3%:16
        #    5%:99_967
        #    8%:16
        #    => 16+99967+16=99999
        #
        # 引数に入ってきたamountと分割したamountの合計を合わせるために
        # ズレている金額を最も少ない消費税額に属するamountに足すようにする。
        # 最も少ない消費税額に属するamountに不足分を足すのは、
        # これを元に消費税が計算された場合にユーザ有利になるようにという配慮。
        # 例1:
        #    amount: 100000, start_on: 1997/3/31, end_on 2014/4/1の場合
        #    3%:17 <-本当は16だが、1円足す
        #    5%:99_967
        #    8%:16
        #    => 17+99967+16=100000
        #
        # 例2:
        #    amount: 100000, start_on: 2014/3/31, end_on 2019/10/1の場合
        #    5%:51 <-本当は49だが、2円足す
        #    8%:99_900
        #    10%:49
        #    => 51+99900+49=100000
        #
        # FIXME: Enumerable#sumはruby 2.4からサポートされているが、本gemはruby 2.3系をまだサポートする必要がある為reduceを使っている
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
end
