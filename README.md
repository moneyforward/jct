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

date = Date.new(2019, 9, 30)
Jct.amount_with_tax(100, date: date) # => 108
Jct.rate(date)                       # => 1.08

# If `date` is not passed, the excise tax rate based on `Date.today` is used
if Date.today == Date.new(2019, 10, 1)
  Jct.amount_with_tax(100)                   # => 110
  Jct.rate                                   # => 1.1

  Jct.amount_with_tax(999)                   # => 1098
  Jct.amount_with_tax(999, fraction: :floor) # => 1098
  Jct.amount_with_tax(999, fraction: :ceil)  # => 1099
end
```

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/moneyforward/jct.

### tips
- Please separate the PR for additional features from the PR for versioning.
