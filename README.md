# Geld::Excise

## Installation

    $ gem install geld-excise

## Usage
```ruby
require 'geld-excise'

today = Date.new(2014, 3, 31)
Geld::Excise.amount_with_tax(100, date: today)      # => 105
Geld::Excise.rate(today)                            # => 1.05

Geld::Excise.amount_with_tax(100)                   # => 108
Geld::Excise.rate                                   # => 1.08

# Calculate using 10% sales tax from 10/01/2019.
today = Date.new(2019, 10, 1)
Geld::Excise.amount_with_tax(100)                   # => 110
Geld::Excise.rate                                   # => 1.1

Geld::Excise.amount_with_tax(999)                   # => 1078
Geld::Excise.amount_with_tax(999, fraction: :floor) # => 1078
Geld::Excise.amount_with_tax(999, fraction: :ceil)  # => 1079
```

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/moneyforward/geld-excise.

### tips
- Please separate the PR for additional features from the PR for versioning.

