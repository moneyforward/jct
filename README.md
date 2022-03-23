<div align="center">

# Jct

Japanese excise tax calculator

[![github workflow status](https://img.shields.io/github/workflow/status/moneyforward/jct/CI/main)](https://github.com/moneyforward/jct/actions) [![crates](https://img.shields.io/gem/v/jct)](https://rubygems.org/gems/jct)

</div>

## Installation

```
$ gem install jct
```

## Usage
```ruby
require 'jct'

today = Date.new(2014, 3, 31)
Jct.amount_with_tax(100, date: today)      # => 105
Jct.rate(today)                            # => 1.05

Jct.amount_with_tax(100)                   # => 108
Jct.rate                                   # => 1.08

# Calculate using 10% sales tax from 10/01/2019.
today = Date.new(2019, 10, 1)
Jct.amount_with_tax(100)                   # => 110
Jct.rate                                   # => 1.1

Jct.amount_with_tax(999)                   # => 1078
Jct.amount_with_tax(999, fraction: :floor) # => 1078
Jct.amount_with_tax(999, fraction: :ceil)  # => 1079
```

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/moneyforward/jct.

### tips
- Please separate the PR for additional features from the PR for versioning.

