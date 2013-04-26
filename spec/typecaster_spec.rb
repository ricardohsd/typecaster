require 'spec_helper'

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

class ObjectFormatter
  include Typecaster

  attribute :age, :size => 3, :position => 2, :caster => IntegerTypecaster

  with_options :caster => StringTypecaster, :size => 10 do
    attribute :name, :position => 1
    attribute :identification, :position => 3, :default => "*"
  end
end

class AnotherObjectFormatter
  include Typecaster

  output_separator ";"

  attribute :age, :size => 3, :position => 2, :caster => IntegerTypecaster

  with_options :caster => StringTypecaster, :size => 10 do
    attribute :name, :position => 1
    attribute :identification, :position => 3, :default => "*"
  end
end

describe Typecaster do
  context "generating" do
    context "without values" do
      subject do
        ObjectFormatter.new
      end

      it "should return formatted values" do
        expect(subject.to_s).to eq "*         "
      end
    end

    context "with values" do
      subject do
        ObjectFormatter.new(:name => "Ricardo", :age => 23, :identification => "R")
      end

      it "calls the caster class with the attribute options" do
        attributes = { :default => "*", :caster => StringTypecaster, :size => 10, :value => "*", :attribute => :identification }

        StringTypecaster.should_receive(:call).with("*", attributes)

        ObjectFormatter.new
      end

      it "should return formatted name" do
        expect(subject.attributes[:name]).to eq "Ricardo   "
      end

      it "should return formatted age" do
        expect(subject.attributes[:age]).to eq "023"
      end

      it "should return identification with default value" do
        expect(subject.attributes[:identification]).to eq "R         "
      end

      it "should return formatted values" do
        expect(subject.to_s).to eq "Ricardo   023R         "
      end

      context "with a collection of values" do
        subject do
          ObjectFormatter.new([{ :name => "Ricardo", :age => 23, :identification => "R" }, { :name => "Cairo", :age => 26, :identification => "C" }])
        end

        let(:first_object) { ObjectFormatter.new(:name => "Ricardo", :age => 23, :identification => "R") }

        let(:second_object) { ObjectFormatter.new(:name => "Cairo", :age => 26, :identification => "C") }

        context "#collection" do
          specify { expect(subject.collection).to eq [first_object, second_object] }
          specify { expect(subject.collection.first).to eq first_object }
          specify { expect(subject.collection.last).to eq second_object }
        end

        specify { expect(subject.to_s).to eq "Ricardo   023R         \nCairo     026C         " }
      end
    end

    context "with invalid values" do
      it "should raise an error for the invalid field" do
        expect(lambda {
          ObjectFormatter.new(:name => "Ricardo", :age => 23, :xpto => "R")
        }).to raise_error("attribute xpto is not defined")
      end
    end
  end

  context "parsing a line" do
    let :text do
      "Ricardo   023R         "
    end

    it "should parse text" do
      expect(ObjectFormatter.parse(text)).to eq({ :name => "Ricardo", :age => 23.0, :identification => "R" })
    end
  end

  context "parsing a file" do
    let :file do
      File.open("spec/fixtures/sample_uniform_file.txt", "r")
    end

    it "should parse file content" do
      parsed_content = ObjectFormatter.parse_file(file)
      expect(parsed_content).to eq([
        {
          :name => "RICARDOHEN",
          :age => 24,
          :identification => "123"
        },
        {
          :name => "ANACLAUDIA",
          :age => 23,
          :identification => "222"
        }
      ])
    end
  end
end
