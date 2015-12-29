require "mt/version"
require 'fileutils'
require 'mt/repo'
require 'mt/mock_build'
require 'mt/spec_tool'
require 'mt/ext/string'

module Mt

  def self.init
    ["specs", "sources", "tmp", "result"].each do |i|
      FileUtils.mkdir_p "#{Dir.home}/.mt/#{i}"
    end
  end

  def self.build(raw_spec, mockroot: , repo_dir:, env:)
    puts %(#{"build".bold.blue} #{raw_spec.bold.grey} )
    repo = Repo.new(repo_dir)

    spec_tool = SpecTool.new(raw_spec, env: env)
    srpm = spec_tool.build_srpm
  
    mock_build = MockBuild.new(srpm, root: mockroot)
    mock_build.build

    repo.add(mock_build)
  end

end
