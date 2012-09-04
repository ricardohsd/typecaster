require "typecaster/version"
require "typecaster/parser"

module Typecaster
  def self.included(base)
    base.extend ClassMethods
  end

  module ClassMethods
    def attribute(name, options = {})
      attribute_name = name.to_sym

      attributes_options[attribute_name] = options
      attributes[attribute_name] = nil
    end

    def attributes
      @attributes ||= Hash.new
    end

    def attributes_options
      @attributes_options ||= Hash.new
    end

    def parse(text)
      result = Hash.new
      attributes_options.each do |attribute, options|
        result[attribute] = parse_attribute(text.slice!(0...options[:size]), options)
      end
      result
    end

    private

    def parse_attribute(value, options)
      klass = options[:caster]
      klass.parse(value)
    end
  end

  def initialize(params = {})
    attributes_with_default.each do |key, options|
      define_value(key, options[:default])
    end

    params.each do |key, value|
      define_value(key, value)
    end
  end

  def attributes
    @attributes ||= self.class.attributes
  end

  def to_s
    attributes.values.join("")
  end

  private

  def attributes_options
    @attributes_options ||= self.class.attributes_options
  end

  def attributes_with_default
    attributes_options.select { |key, options| options.has_key?(:default) }
  end

  def typecasted_attribute(options)
    klass = options[:caster]
    klass.call(options[:value], options)
  end

  def define_value(name, value)
    attributes_options[name][:value] = value
    value = typecasted_attribute(attributes_options[name])
    attributes[name] = value
  end
end
