require 'ostruct'
require 'erb'
require_relative 'error'

module Mt
  class GemDSL

    attr_reader :env, :file

    def initialize(file, env: {})
      @file = file.to_s
      @env = env
    end

    def config
      return @config if @config
      @config = {
        name: nil,
        version: nil,
        release: nil,
        requires: [],
        build_requires: [],
        ruby_version: nil,
        ruby_major_version: nil
      }
      read_from_file file
      validate! @config
      @config
    end

    def render
      erb = ERB.new(File.read(template), nil, '-')
      erb.result binding
    end

    private

    def env(key)
      @env.fetch key.to_s 
    end

    def template
      @template ||= "#{__dir__}/templates/gem.spec"
    end

    def name(name)
      set :name, name
    end

    def version(version)
      set :version, version
    end

    def release(release)
      set :release, release
    end

    def requires(requires)
      @config[:requires] << requires
    end

    def build_requires(requires)
      @config[:build_requires] << requires
    end

    def ruby_version(ruby_version)
      set :ruby_version, ruby_version
      set :ruby_major_version, ruby_major_version
    end

    def ruby_major_version
      split = @config[:ruby_version].split(".")
      major = split[0]
      minor = split[1]
      "#{major}.#{minor}.0"
    end

    def read_from_file(file)
      if not File.readable? file
        raise Error, " #{file} not readable"
      end 
      instance_eval File.read(file), file.to_s
    rescue NoMethodError => e
      raise "invalid option used in #{file}: #{e.name}"
    end

    def set(key, value)
      @config.store key, value
    end  

    def validate!(hash)
      hash.each do |k, v|
        raise Error, "config #{k} is nil in #{file}" if v.nil?
      end
    end

    def binding
      ostruct = OpenStruct.new(config)
      ostruct.instance_eval { binding }
    end

  end
end
