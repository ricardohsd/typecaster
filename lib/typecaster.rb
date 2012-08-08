require "active_support"
require "typecaster/version"

module Typecaster
  extend ActiveSupport::Concern

  module ClassMethods
    def attribute(name, options={})
      attribute_name = name.to_sym

      raw_attributes[attribute_name] = options
      attributes[attribute_name] = nil

      define_method(name) do
        if instance_variable_defined?("@#{name}")
          instance_variable_get("@#{name}")
        elsif raw_attributes[attribute_name].has_key?(:default)
          define_instance_variable(name, raw_attributes[attribute_name][:default])
        else
          define_instance_variable(name, nil)
        end
      end

      define_method("#{name}=") do |val|
        define_instance_variable(name, val)
      end
    end

    def attributes
      @attributes ||= Hash.new
    end

    def raw_attributes
      @raw_attributes ||= Hash.new
    end
  end

  def initialize(attributes={})
    raw_attributes.each do |name, attributes|
      if attributes.has_key?(:default)
        define_instance_variable(name, attributes[:default])
      end
    end

    attributes.each do |key, value|
      send "#{key}=", value
    end
  end

  def attributes
    @attributes ||= self.class.attributes
  end

  def raw_attributes
    @raw_attributes ||= self.class.raw_attributes
  end

  def to_row
    attributes.values.join("")
  end

  private

  def typecasted_attribute(options)
    klass = options[:class]
    klass.new.call(options[:value], options)
  end

  def define_instance_variable(name, val)
    raw_attributes[name][:value] = val
    val = typecasted_attribute(raw_attributes[name])
    attributes[name] = val
    instance_variable_set("@#{name}", val)
  end
end
