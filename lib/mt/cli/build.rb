require 'mt'
require 'mt/error'
require 'optparse'
require 'yaml'

module Mt
  module Cli
    class Build
    
      def initialize(argv)
        @argv = argv.dup
        @options = {}
      end

      def parse_opts
        OptionParser.new do |opts|
          opts.on("-v", "--[no-]verbose", "Run verbosely") do |v|
            @options[:verbose] = v
          end

          opts.on("-r", "--root MOCKROOT" , "Specify mock root") do |r|
            @options[:mockroot] = r
          end

        end.parse!(@argv)
      end

      def run
        parse_opts
        spec_path = @argv.shift
        mockroot = @options[:mockroot]

        raise Error, "spec path must be specified" if not spec_path
        raise Error, "must specify mock root using -r" if not mockroot
        Mt.init
        config
        
        repo_dir = repo_dir(mockroot)
        env = config["env"] || {}
        Mt.build(spec_path, mockroot: mockroot, repo_dir: repo_dir, env: env)
      end

      private

      def config
        @config ||= load_config
      end

      def load_config
        YAML.load_file "#{Dir.home}/.mt/config.yml"
      rescue => e 
        raise Error, "unable to read config file: #{e.message}"
      end

      def repo_dir(root)
        roots = config.fetch("roots")
        repo_dir = roots[root]
      rescue => e
        raise Error, "unable to find repo_dir for mockroot #{root}: #{e.message}"
      end

    end
  end
end
