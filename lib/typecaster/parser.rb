module Typecaster
  module Parser
    def self.included(base)
      base.extend ClassMethods
    end

    module ClassMethods
      def parser(name, options = {})
        parsers_options[name.to_sym] = options
      end

      def parse(file)
        result = {}

        file.each_line do |line|
          parser = find_parser_by_identifier(line)
          options = parsers_options[parser]

          line_parser = options[:with]
          content = line_parser.parse(line)

          if options[:array]
            result.merge! parser => [] unless result[parser]

            parsed = content
            content = result[parser]
            content << parsed
          end

          result.merge! parser => content
        end

        new(result)
      end

      private

      def parsers_options
        @parsers_options ||= Hash.new
      end

      def find_parser_by_identifier(line)
        parsers_options.each do |parser_name, options|
          identifier = options[:identifier]

          return parser_name unless identifier

          return parser_name if line.start_with? identifier
        end
      end
    end

    def initialize(attributes = {})
      attributes.each do |key, value|
        (class << self; self; end).send(:define_method, "#{key}") do
          value
        end
      end
    end
  end
end
