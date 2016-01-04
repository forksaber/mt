require 'pathname'
require 'fileutils'
require 'mt/helper'

module Mt
  class MockBuild

    include Helper

    def initialize(source_srpm_path, root:)
      @source_srpm_path = source_srpm_path
      @result_dir = "#{Dir.home}/.mt/result"
      @root = root
    end

    def build
      clean_result_dir
      cmd %(mock -r #{@root} --rebuild "#{@source_srpm_path}" --resultdir "#{@result_dir}")
    end

    def rpms
      all_rpms.reject { |a| a =~ /(-debuginfo-)|(.src.rpm\z)/ }
    end

    def srpms
      Dir.glob("#{@result_dir}/*.src.rpm")
    end

    def debuginfo
      all_rpms.select{ |a| a =~ /-debuginfo-/ }
    end 

    private

    def all_rpms
      Dir.glob("#{@result_dir}/*.rpm")
    end

    def clean_result_dir
      FileUtils.rm Dir["#{@result_dir}/*"]
    end

  end
end
