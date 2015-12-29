require_relative 'helper'
require_relative 'curl'
require_relative 'error'
require_relative 'gem_spec'
require_relative 'spec'

module Mt
  class SpecTool

    include Helper

    def initialize(spec, downloads_dir: nil, env: {})
      @spec = new_spec(spec, env: env)
      @downloads_dir = downloads_dir || "#{Dir.home}/.mt/sources"
    end

    def build_srpm
      download_sources
      Dir.mktmpdir "srpm-", "#{Dir.home}/.mt/tmp" do |dir|
        copy_sources dir
        output = cmd %(rpmbuild  --define "_sourcedir #{dir}" -bs "#{rendered_spec}"),
                  return_output: true
        path = output.gsub("Wrote: ", "").chomp
      end
    end

    def render(path)
      File.open(path, 'w') { |f| f.write @spec.render }
      path
    end

    def rendered_spec
      @rendered_spec ||= begin
        path = "#{Dir.home}/.mt/specs/#{@spec.name}.spec"
        render path
      end
    end

    def sources
      @sources ||= raw_sources.map { |i| i[/[^\/]+\z/] } 
    end

    def http_sources
      @http_sources ||= raw_sources.select { |i| i =~ /\A(http|https):/ }
    end

    def copy_sources(dest_dir)
      sources.each do |s|
        copy_source s, dest_dir
      end
    end

    def download_sources
      case @spec
      when Spec
        download_http_sources @downloads_dir
      when GemSpec
        download_gem @downloads_dir
      end
    end

    private

    def new_spec(raw_spec, env:)
      case raw_spec
      when /\.spec.rb\z/
        GemSpec.new raw_spec, env: env
      else
        Spec.new raw_spec, env: env
      end
    end

    def raw_sources
      @raw_sources ||= begin
        `spectool #{rendered_spec}`.lines
        .map { |i| i.partition(":")[2].chomp.strip }
      end
    end

    def download_http_sources(dest_dir)
      http_sources.each do |url|
        filename = url[/[^\/]+\z/]
        outfile = "#{dest_dir}/#{filename}"
        next if File.exist? outfile
        curl.download url, outfile
      end
    end

    def download_gem(dest_dir)
      name = @spec.gem_name
      version = @spec.gem_version
      filename = "#{name}-#{version}.gem"
      Dir.chdir dest_dir do
        next if File.exist? filename
        system "gem fetch '#{name}' -v '#{version}'"
      end
    end

    def copy_source(name, dest_dir)
      source_locations = [
        @downloads_dir,
        @spec.dir
      ]
      source_dir = source_locations.find { |dir| File.exist? "#{dir}/#{name}" }
      raise Error, "#{name} not found in any source dirs" if not source_dir
      FileUtils.cp "#{source_dir}/#{name}", "#{dest_dir}/#{name}"
    end

    def curl
      @curl ||= Curl.new
    end

  end
end
