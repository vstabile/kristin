require "kristin/version"

module Kristin
  def self.convert(source, target)
    unless File.exists?(source) 
      raise IOError, "Source file (#{source}) does not exist."
    end

    unless which("pdf2htmlex") || which("pdf2htmlEX")
      raise IOError, "Can't find pdf2htmlex executable in PATH"
    end

    ## TODO: determine exact command
    
    cmd = "pdf2htmlex #{source} #{target}"
    system("#{cmd} > /dev/null")
  end

  private

  def self.which(cmd)
    exts = ENV['PATHEXT'] ? ENV['PATHEXT'].split(';') : ['']
    ENV['PATH'].split(File::PATH_SEPARATOR).each do |path|
      exts.each do |ext|
        exe = File.join(path, "#{cmd}#{ext}")
        
        return exe if File.executable? exe
      end
    end
    
    return nil
  end
end