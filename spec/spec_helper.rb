require 'rspec'
require 'typecaster'

module StringTypecaster
  def self.call(value, options)
    value.to_s.ljust(options[:size], " ")
  end

  def self.parse(value)
    value.strip
  end
end

module IntegerTypecaster
  def self.call(value, options)
    value.to_s.rjust(options[:size], "0")
  end

  def self.parse(value)
    value.to_f
  end
end
