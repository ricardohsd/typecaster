# Typecaster

This gem was built for create text files based in fixed columns.

## Instalation

  gem install typecaster

## Usage

Given you need generate a text with the following format:
```
  column name | size  | starting | ending | type   |
  name        | 10    | 0        | 9      | string |
  price       | 8     | 10       | 17     | number |
  code        | 6     | 18       | 23     | string |
```
Here's how to use it:
```
  module StringTypecaster
    def self.call(value, options)
      value.to_s.ljust(options[:size], " ")
    end
  end

  module NumerTypecaster
    def self.call(value, options)
      value.to_s.rjust(options[:size], "0")
    end
  end

  class ProductFormatter
    include Typecaster

    attribute :name, :size => 10, :class => StringTypeCaster
    attribute :price, :size => 8, :class => NumberTypeCaster
    attribute :code, :size => 6, :class => StringTypeCaster
  end

  product = ProductFormatter.new(:name => 'Coca', :price => '25.0', :code => '6312')
  puts product.to_s # => 'Coca      000025.06312  '
```

## Contributing

* Fork the project.
* Make your feature addition or bug fix.
* Add tests for it.
* Commit, do not mess with rakefile, version, or history.
* Send me a pull request.
