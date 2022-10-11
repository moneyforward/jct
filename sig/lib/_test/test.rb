# Write Ruby code to test the RBS.
# It is type checked by `steep check` command.

require 'jct'

Jct::VERSION

date = Date.new(2019, 9, 30)
Jct.amount_with_tax(100, date: date)

start_on = Date.new(2018, 4, 1)
end_on = Date.new(2022, 4, 1)
Jct.yearly_amount_with_tax(amount: 100, start_on: start_on, end_on: end_on)
Jct.amount_separated_by_rate(amount: 100, start_on: start_on, end_on: end_on)

Jct.rate
