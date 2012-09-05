require 'spec_helper'

module StringTypecaster
  def self.parse(string)
    string.strip
  end
end

module IntegerTypecaster
  def self.parse(string)
    string.to_i
  end
end

class ObjectHeader
  include Typecaster

  attribute :row_number, :size => 6, :position => 3, :caster => IntegerTypecaster

  with_options :caster => StringTypecaster do
    attribute :identifier, :size => 1,  :position => 1
    attribute :text,       :size => 20, :position => 2
  end
end

class ObjectRow
  include Typecaster

  with_options :caster => StringTypecaster do
    attribute :identifier, :size => 1,  :position => 1
    attribute :person,     :size => 15, :position => 3
  end

  with_options :caster => IntegerTypecaster do
    attribute :amount,     :size => 5, :position => 2
    attribute :row_number, :size => 6, :position => 4
  end
end

class ObjectFooter
  include Typecaster

  with_options :caster => StringTypecaster do
    attribute :identifier, :size => 1,  :position => 1
    attribute :filler,     :size => 15, :position => 3
  end

  with_options :caster => IntegerTypecaster do
    attribute :total,      :size => 5, :position => 2
    attribute :row_number, :size => 6, :position => 4
  end
end

class ObjectFile
  include Typecaster::Parser

  parser :header, :with => ObjectHeader, :identifier => '0'
  parser :rows, :with => ObjectRow, :identifier => '1', :array => true
  parser :footer, :with => ObjectFooter, :identifier => '9'
end

describe Typecaster::Parser do
  describe 'parsing a file' do
    let :file do
      File.new('spec/fixtures/sample.txt')
    end

    subject do
      ObjectFile.parse(file)
    end

    it 'should parse the header' do
      expect(subject[:header]).to eq(:identifier => "0", :text => "SOME IMPORTANT TEXT", :row_number => 1)
    end

    it 'should parse the rows' do
      expect(subject[:rows]).to eq([
              { :identifier => "1", :amount => 19999, :person => "FOO BAR",  :row_number => 2 },
              { :identifier => "1", :amount => 10000, :person => "XPTO BAR", :row_number => 3 },
              { :identifier => "1", :amount => 9901,  :person => "JOAO BAR", :row_number => 4 }
      ])
    end

    it 'should parse the footer' do
      expect(subject[:footer]).to eq(:identifier => "9", :total => 39900, :filler => "", :row_number => 5)
    end
  end
end
