require 'pathname'
require_relative 'error'
require_relative 'gem_dsl'

module Mt
  class GemSpec

    attr_reader :raw_spec

    def initialize(raw_spec, env: {})
      @raw_spec = Pathname.new(raw_spec)
      @env = env
    end

    def name
      @name ||= raw_spec.basename.to_s.gsub(/\.spec\.rb\z/, '')
    end

    def dir
      @dir ||= raw_spec.dirname.to_s
    end

    def render
      dsl.render
    end

    def gem_name
      dsl.config[:name]
    end

    def gem_version
      dsl.config[:version]
    end

    private

    def dsl
      @dsl ||= GemDSL.new(raw_spec, env: @env)
    end
  end
end
