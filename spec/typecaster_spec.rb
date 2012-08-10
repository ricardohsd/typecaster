require 'spec_helper'

class StringTypecaster
  def call(value, options)
    value.to_s.ljust(options[:size], " ")
  end
end

class IntegerTypecaster
  def call(value, options)
    value.to_s.rjust(options[:size], "0")
  end
end

class ObjectFormatter
  include Typecaster

  attribute :name, :size => 10, :class => StringTypecaster
  attribute :age, :size => 3, :class => IntegerTypecaster
  attribute :identification, :size => 5, :class => StringTypecaster, :default => "*"
end

describe Typecaster do
  context "without values" do
    subject do
      ObjectFormatter.new
    end

    it "should return formatted values" do
      subject.to_s.should eq "*    "
    end
  end

  context "with values" do
    subject do
      ObjectFormatter.new(:name => "Ricardo", :age => 23, :identification => "R")
    end

    it "should return formatted name" do
      subject.attributes[:name].should eq "Ricardo   "
    end

    it "should return formatted age" do
      subject.attributes[:age].should eq "023"
    end

    it "should return identification with default value" do
      subject.attributes[:identification].should eq "R    "
    end

    it "should return formatted values" do
      subject.to_s.should eq "Ricardo   023R    "
    end
  end
end
