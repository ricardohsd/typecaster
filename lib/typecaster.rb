require "typecaster/version"
require "typecaster/parser"
require "typecaster/hash"

module Typecaster
  def self.included(base)
    base.extend ClassMethods
  end

  module ClassMethods
    attr_writer :options

    def with_options(options, &block)
      self.options = options

      instance_eval(&block)

      self.options = Hash.new
    end

    def attribute(name, options = {})
      raise "missing :position key to `:#{name}`" unless options.has_key?(:position)

      attribute_name, position = name.to_sym, options.delete(:position)

      options.merge!(self.options)

      attributes_options[position] = Hash[attribute_name => options]
      attributes[position] = Hash[attribute_name => nil]
    end

    def options
      @options ||= Hash.new
    end

    def attributes
      @attributes ||= Hash.new
    end

    def attributes_options
      @attributes_options ||= Hash.new
    end

    def parse(text)
      result = Hash.new
      attributes_options.order.each do |attribute, options|
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
    @attributes ||= self.class.attributes.order
  end

  def to_s
    attributes.values.join("")
  end

  private

  def attributes_options
    @attributes_options ||= self.class.attributes_options.order
  end

  def attributes_with_default
    attributes_options.select { |key, options| options.has_key?(:default) }
  end

  def typecasted_attribute(options)
    klass = options[:caster]
    klass.call(options[:value], options)
  end

  def define_value(name, value)
    raise "attribute #{name} is not defined" if attributes_options[name].nil?

    attributes_options[name][:value] = value
    value = typecasted_attribute(attributes_options[name])
    attributes[name] = value
  end
end
