require 'fileutils'
require 'tmpdir'

module Mt
  class Curl

    def initialize
      create_tmpdir
    end

    def download(url, outfile)
      Dir.mktmpdir "curl", tmpdir do |d|
        tmpfile = "#{d}/f"
        puts "downloading #{url}"
        command = %(curl -# -L -w "%{http_code}" -f -o '#{tmpfile}' '#{url}')
        http_status = `#{command}`
        exit_status = $?.exitstatus
        if (http_status != "200" || exit_status != 0)
          raise "failed to download #{outfile}, http status #{http_status}, exit_status #{exit_status}"
        end
        FileUtils.mv tmpfile, outfile
      end
    end

    private

    def tmpdir
      @tmpdir ||= "#{Dir.home}/.mt/tmp"
    end

    def create_tmpdir
      FileUtils.mkdir_p(tmpdir)
    end

  end
end
