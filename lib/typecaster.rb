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

  def typecaster
    {}
  end

  def typecasted_attribute(attribute_name, options)
    type = options[:type]
    typecast_attribute(type).call(options[:value], options)
  end

  def typecast_attribute(type)
    typecaster[type].new if typecaster
  end

  def define_instance_variable(name, val)
    raw_attributes[name][:value] = val
    val = typecasted_attribute(name, raw_attributes[name])
    attributes[name] = val
    instance_variable_set("@#{name}", val)
  end
end