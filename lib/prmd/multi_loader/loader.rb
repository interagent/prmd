module Prmd #:nodoc:
  module MultiLoader #:nodoc:
    # Exception raised when a extension loader cannot be found.
    class LoaderNotFound < StandardError
    end

    # @return [Hash<String, Prmd::MultiLoader::Loader>]
    @file_extensions = {}

    class << self
      attr_accessor :file_extensions
    end

    # Attempts to autoload a Loader named +name+
    #
    # @param [String]
    # @return [Boolean]  load success
    def self.autoload_loader(name)
      # extension names are preceeded with a .
      # TODO. probably just remove the first .
      loader_name = name.gsub('.', '')
      require "prmd/multi_loader/#{loader_name}"
      true
    rescue
      false
    end

    # Locates and returns a loader for the given +ext+
    # If no extension is found the first time, MultiLoader will attempt
    # to load one of the same name.
    #
    # @param [String] ext
    # @return [Prmd::MultiLoader::Loader]
    # @eg
    #   # by default, Prmd does not load the TOML Loader
    #   MultiLoader.loader('.toml')
    #   # this will check the loaders the first time and find that
    #   # there is no Loader for toml, it will then use the ::autoload_loader
    #   # to locate a Loader named "prmd/multi_loader/toml"
    def self.loader(name)
      tried_autoload = false
      begin
        @file_extensions.fetch(name)
      rescue KeyError
        if tried_autoload
          raise LoaderNotFound, "Loader for extension (#{name}) was not found."
        else
          autoload_loader(name)
          tried_autoload = true
          retry
        end
      end
    end

    # @param [String] ext
    # @param [String] data
    # @eg
    #   Prmd::MultiLoader.load_data('.json', json_string)
    def self.load_data(ext, data)
      loader(ext).load_data(data)
    end

    # @param [String] ext  name of the loader also the extension of the stream
    # @param [IO] stream
    # @eg
    #   Prmd::MultiLoader.load_stream('.json', io)
    def self.load_stream(ext, stream)
      loader(ext).load_stream(stream)
    end

    # Shortcut for loading any supported file
    #
    # @param [String] ext
    # @param [String] filename
    # @eg
    #   Prmd::MultiLoader.load_file('my_file.json')
    def self.load_file(filename)
      ext = File.extname(filename)
      loader(ext).load_file(filename)
    end

    # Base Loader module used to extend all other loaders
    module Loader
      # Using the loader, parse or do whatever magic the loader does to the
      # string to get back data.
      #
      # @param [String] data
      # @return [Object]
      # @abstract
      def load_data(data)
        # overwrite in children
      end

      # Load a stream
      #
      # @param [IO] stream
      # @return [Object]
      # @eg
      #   my_io = File.open('my_file.ext', 'r')
      #   my_loader.load_stream(my_io)
      def load_stream(stream)
        load_data(stream.read)
      end

      # Load a file given a +filename+
      #
      # @param [String] filename
      # @return [Object]
      # @eg
      #   my_loader.load_file('my_file.ext')
      def load_file(filename)
        File.open(filename, 'r') { |f| return load_stream(f) }
      end

      # Register the loader to the +args+ extensions
      #
      # @param [Array<String>] args
      # @eg extensions '.json'
      def extensions(*args)
        args.each do |file|
          Prmd::MultiLoader.file_extensions[file] = self
        end
      end

      private :extensions
    end
  end
end
