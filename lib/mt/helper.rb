require_relative 'ext/string'

module Mt
  module Helper

    def cmd(command, error_msg: nil, return_output: false)
      puts "#{"\u2023".bold.green} #{command}"
      if return_output
        output = `#{command}`
      else
        output = ""
        system "#{command} 2>&1"
      end
      return_value = $?.exitstatus
      error_msg ||= "Non zero exit for \"#{command}\""
      raise ::Mt::Error, error_msg if return_value !=0 
      return output
    end 

  end 
end
