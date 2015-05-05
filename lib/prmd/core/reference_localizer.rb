# :nodoc:
module Prmd
  # @api private
  # Schema references localizer
  class ReferenceLocalizer
    attr_reader :object

    # @param [Object] object
    def initialize(object)
      @object = object
    end

    # @param [Object] object
    # @return [ReferenceLocalizer]
    def self.build(object)
      case object
      when Array
        ForArray
      when Hash
        ForHash
      else
        self
      end.new(object)
    end

    # @param [Object] object
    # @return [Object]
    def self.localize(object)
      build(object).localize
    end

    # @return [Object]
    def localize
      object
    end

    private :object

    # @api private
    # Schema references localizer for arrays
    class ForArray < self
      alias_method :array, :object

      # @return [Array]
      def localize
        array.map { |element| ReferenceLocalizer.localize(element) }
      end
    end

    # @api private
    # Schema references localizer for hashes
    class ForHash < self
      alias_method :hash, :object

      # @return [Hash]
      def localize
        localize_ref
        localize_href
        localize_values
      end

      def localize_ref
        return unless hash.key?('$ref')
        hash['$ref'] = '#/definitions' + local_reference
      end

      def localize_href
        return unless hash.key?('href') && hash['href'].is_a?(String)
        hash['href'] = hash['href'].gsub('%23', '')
                       .gsub(/%2Fschemata(%2F[^%]*%2F)/,
                             '%23%2Fdefinitions\1')
      end

      # @return [Hash]
      def localize_values
        hash.each_with_object({}) { |(k, v), r| r[k] = ReferenceLocalizer.localize(v) }
      end

      # @return [String]
      def local_reference
        ref = hash['$ref']
        # clean out leading #/definitions to not create a duplicate one
        ref = ref.gsub(/^#\/definitions\//, '#/') while ref.match(/^#\/definitions\//)
        ref.gsub('#', '').gsub('/schemata', '')
      end

      private :localize_ref
      private :localize_href
      private :localize_values
      private :local_reference
    end
  end
end
