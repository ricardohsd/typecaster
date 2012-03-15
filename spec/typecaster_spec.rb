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

  attribute :name, :type => "string", :size => 10
  attribute :age, :type => "integer", :size => 3
  attribute :identification, :type => "string", :size => 5, :default => "*"

  def typecaster
    {
      "string"  => StringTypecaster,
      "integer" => IntegerTypecaster
    }
  end
end

describe Typecaster do
  context "without values" do
    subject do
      ObjectFormatter.new
    end

    it "should return row" do
      subject.to_row.should eq "*    "
    end
  end

  context "with values" do
    subject do
      ObjectFormatter.new(:name => "Ricardo", :age => 23, :identification => "R")
    end

    it "should return formatted name" do
      subject.name.should eq "Ricardo   "
      subject.attributes[:name].should eq "Ricardo   "
    end

    it "should return formatted age" do
      subject.age.should eq "023"
      subject.attributes[:age].should eq "023"
    end

    it "should return identification with default value" do
      subject.identification.should eq "R    "
      subject.attributes[:identification].should eq "R    "
    end

    it "should return row" do
      subject.to_row.should eq "Ricardo   023R    "
    end
  end
end
