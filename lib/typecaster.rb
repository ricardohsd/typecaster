require "typecaster/version"
require "typecaster/parser"
require "typecaster/hash"

module Typecaster
  def self.included(base)
    base.extend ClassMethods
  end

  module ClassMethods
    attr_writer :options

    def attribute(name, options = {})
      raise "missing :position key to `:#{name}`" unless options.has_key?(:position)

      attribute_name, position = name.to_sym, options.delete(:position)

      options.merge!(self.options)

      attributes_options[position] = Hash[attribute_name => options]
      attributes[position] = Hash[attribute_name => nil]
    end

    def attributes
      @attributes ||= Hash.new
    end

    def attributes_options
      @attributes_options ||= Hash.new
    end

    def output_separator(separator)
      @output_separator = separator
    end

    def options
      @options ||= Hash.new
    end

    def parse(text)
      result = Hash.new
      attributes_options.order.each do |attribute, options|
        result[attribute] = parse_attribute(text.slice!(0...options[:size]), options)
      end
      new(result, true)
    end

    def parse_file(file)
      result = []

      file.each_line do |line|
        result << parse(line)
      end

      result
    end

    def separator
      @output_separator ||= ""
    end

    def with_options(options, &block)
      self.options = options

      instance_eval(&block)

      self.options = Hash.new
    end

    private

    def parse_attribute(value, options)
      klass = options[:caster]
      klass.parse(value)
    end
  end

  def initialize(params = {}, parsing = false)
    @parsing = parsing

    if params.is_a?(Array)
      return params.each do |param|
        collection << self.class.new(param)
      end
    end

    # Setup attributes with the default option
    attributes_with_default.each do |key, options|
      define_value(key, options[:default])
    end

    # Assign the param to the attribute
    params.each do |key, value|
      define_value(key, value)
    end
  end

  def attributes
    @attributes ||= self.class.attributes.order
  end

  def collection
    @collection ||= []
  end

  def ==(value)
    if value.is_a? Hash
      to_h == value
    else
      to_s == value.to_s
    end
  end

  def to_h
    attributes
  end

  def to_s
    if collection.any?
      collection.map(&:to_s).join("\n")
    else
      attributes.values.join(self.class.separator)
    end
  end

  private

  def attributes_options
    @attributes_options ||= self.class.attributes_options.order
  end

  def attributes_with_default
    attributes_options.select { |_, options| options.has_key?(:default) }
  end

  def define_value(name, value)
    raise "attribute #{name} is not defined" if attributes_options[name].nil?

    attributes_options[name][:value] = value
    attributes_options[name][:attribute] = name

    unless @parsing
      value = typecasted_attribute(attributes_options[name])
    end

    attributes[name] = value

    (class << self; self; end).send(:define_method, "#{name}") do
      value
    end
  end

  def typecasted_attribute(options)
    caster = options[:caster]
    caster.call(options[:value], options)
  end
end
