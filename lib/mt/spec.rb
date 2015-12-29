require 'ostruct'
require 'erb'
require 'pathname'
require 'mt/error'
require 'mt/curl'

module Mt
  class Spec

    attr_reader :raw_spec

    def initialize(raw_spec, env: {})
      @raw_spec = Pathname.new(raw_spec)
      @env = env
    end

    def name
      @name ||= raw_spec.basename.to_s.gsub(/\.spec\z/, '')
    end

    def dir
      @dir ||= raw_spec.dirname.to_s
    end

    def render
      raise Error, "specpath #{raw_spec} doesn't exist" if not raw_spec.exist?
      erb = ERB.new(File.read(raw_spec))
      erb.result binding
    end

    private

    def binding
      @binding ||= OpenStruct.new(@env).instance_eval { binding }
    end
   
  end
end
