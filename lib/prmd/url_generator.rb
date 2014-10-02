module Prmd
  class UrlGenerator
    module Generators
      class Default
        def self.generate(params)
          data = {}
          data.merge!(params[:schema].schema_example(params[:link]['schema']))
          generate_params(data)
        end

        def self.param_name(key, prefix, array = false)
          result = if prefix
            "#{prefix}[#{key}]"
          else
            key
          end

          result += "[]" if array
          result
        end

        def self.generate_params(obj, prefix = nil)
          result = []
          obj.each do |key,value|
            if value.is_a?(Hash)
              newprefix = if prefix
                "#{prefix}[#{key}]"
              else
                key
              end
              result << generate_params(value, newprefix)
            elsif value.is_a?(Array)
              value.each do |val|
                result << [param_name(key, prefix, true), CGI.escape(val.to_s)].join('=')
              end
            else
              next unless value # ignores parameters with empty examples
              result << [param_name(key, prefix), CGI.escape(value.to_s)].join('=')
            end
          end
          result.flatten
        end

        class << self
          private :param_name
          private :generate_params
        end
      end

      class JSON
        def self.generate(params)
          data = {}
          data.merge!(params[:schema].schema_example(params[:link]['schema']))

          result = []
          data.sort_by {|k,_| k.to_s }.each do |key, values|
            [values].flatten.each do |value|
              result << [key.to_s, CGI.escape(value.to_s)].join('=')
            end
          end

          result
        end
      end
    end

    def initialize(params)
      @schema = params[:schema]
      @link = params[:link]
      @options = params[:options]
    end

    def url_params
      if @options[:doc][:url_style].downcase == 'json'
        klass = Generators::JSON
      else
        klass = Generators::Default
      end

      klass.generate(schema: @schema, link: @link)
    end
  end
end
