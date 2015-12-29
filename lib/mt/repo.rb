require 'pathname'
require 'fileutils'
require_relative 'helper'
require_relative 'error'

module Mt
  class Repo
   
    include Helper

    def initialize(path)
      raise Error, "repo path cannot be nil" if path.empty?
      @path = Pathname.new path
      init
    end

    def add(mock_build)
      add_rpms mock_build.rpms
      add_srpms mock_build.srpms
      add_debuginfo mock_build.debuginfo
      refresh_db
    end

    private

    def rpms_path
      "#{@path}/rpms"
    end

    def srpms_path
      "#{@path}/srpms"
    end

    def debuginfo_path
      "#{@path}/debuginfo"
    end

    def init
      FileUtils.mkdir_p @path
      %w(rpms srpms debuginfo).each do |i|
        FileUtils.mkdir_p "#{@path}/#{i}"
      end
    end

    def add_rpms(rpms)
      rpms.each do |r| 
        puts "Copying #{r} to #{rpms_path}"
        FileUtils.cp r, rpms_path 
      end
    end

    def add_srpms(srpms)
      srpms.each do |s| 
         puts "Copying #{s} to #{srpms_path}"
        FileUtils.cp s, srpms_path 
      end
    end

    def add_debuginfo(debuginfo)
      debuginfo.each { |d| FileUtils.cp d, debuginfo_path }
    end

    def refresh_db
      cmd "createrepo #{rpms_path}"
      puts "-"*50
      cmd "createrepo #{srpms_path}"
      puts "-"*50
      cmd "createrepo #{debuginfo_path}"
      puts "-"*50
    end

  end
end
