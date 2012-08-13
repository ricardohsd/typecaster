module Typecaster
  module Parser
    def self.included(base)
      base.extend ClassMethods
    end

    module ClassMethods
      def parser(name, options = {})
        parser_name = "#{name}".to_sym
        parsers_options[parser_name] = options
        parsers[parser_name] = nil
      end

      def parsers
        @parsers ||= Hash.new
      end

      def parsers_options
        @parsers_options ||= Hash.new
      end

      def parse(file)
        result = {}

        file.each_line do |line|
          parser = find_parser_by_identifier(line)
          options = parsers_options[parser]

          line_parser = options[:with]
          content = line_parser.parse(line)

          if options[:array]
            parsed = content
            result.merge! parser => [] unless result[parser]

            content = result[parser]
            content << parsed
          end

          result.merge! parser => content
        end

        result
      end

      private

      def find_parser_by_identifier(line)
        parsers_options.each do |parser_name, options|
          identifier = options[:identifier]

          return parser_name unless identifier

          return parser_name if line.start_with? identifier
        end
      end
    end
  end
end
