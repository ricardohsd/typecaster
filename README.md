# Typecaster

This gem was built for create text files based in fixed columns.

## Instalation

  gem install typecaster

## Usage

The Typecaster can be used for two things. To create text files based on positions and read text files based on some descriptor.

### Creating

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

    attribute :code,  :size => 6,  :position => 3, :caster => StringTypecaster
    attribute :name,  :size => 10, :position => 1, :caster => StringTypecaster
    attribute :price, :size => 8,  :position => 2, :caster => NumberTypecaster
  end

  product = ProductFormatter.new(:name => 'Coca', :price => '25.0', :code => '6312')
  puts product.to_s # => 'Coca      000025.06312  '
```

And you also can group the attributes with common options using `with_options` method passing a block
```
  class ProductFormatter
    include Typecaster

    with_options :caster => StringTypecaster do
      attribute :code, :size => 6,  :position => 2
      attribute :name, :size => 10, :position => 1
    end

    attribute :price, :size => 8, :position => 3, :caster => NumberTypecaster
  end
```

### Reading

Given a file like that:

```
0SOME IMPORTANT TEXT 000001
119999FOO BAR        000002
110000XPTO BAR       000003
109901JOAO BAR       000004
939900               000005
```

Each row in that file was identified by a number 0 for header, 1 for the records inside and 9 for footer, each row has 27 chars, to read then you must implement the parsers for each row type.

```
module StringTypecaster
  def self.parse(text)
    text.strip
  end
end

module IntegerTypecaster
  def self.parse(text)
    text.to_i
  end
end

class MyFileHeader
  include Typecaster

  with_options :caster => StringTypecaster do
    attribute :identifier, :size => 1,  :position => 1
    attribute :text,       :size => 20, :position => 2
  end

  attribute :sequential, :size => 5, :position => 3, :caster => IntegerTypecaster
end

class MyFileRow
  include Typecaster

  with_options :caster => StringTypecaster do
    attribute :identifier, :size => 1,  :position => 1
    attribute :name,       :size => 15, :position => 3
  end

  with_options :caster => IntegerTypecaster, :size => 5 do
    attribute :amount,     :position => 2
    attribute :sequential, :position => 4
  end
end

class MyFileFooter
  include Typecaster

  with_options :caster => StringTypecaster do
    attribute :identifier, :size => 1,  :position => 1
    attribute :blanks,     :size => 15, :position => 3
  end

  with_options :caster => IntegerTypecaster do
    attribute :total,      :size => 5, :position => 2
    attribute :sequential, :size => 6, :position => 4
  end
end

class MyFileParser
  include Typecaster::Parse

  parser :header, :with => MyFileHeader, :identifier => '0'
  parser :rows,   :with => MyFileRow,    :identifier => '1', :array => true
  parser :footer, :with => MyFileFooter, :identifier => '9'
end

MyFileParser.parse(File.new('my_file.txt'))
```

Its results in a hash, with keys the following keys: header, rows and footer. The key 'rows' will be an array.

## Contributing

* Fork the project.
* Make your feature addition or bug fix.
* Add tests for it.
* Commit, do not mess with rakefile, version, or history.
* Send me a pull request.
