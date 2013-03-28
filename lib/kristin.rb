require "kristin/version"

module Kristin
  def self.convert(source, target)
    
    raise IOError, "Source file (#{source}) does not exist." if not File.exists?(source)
    raise IOError, "Can't find pdf2htmlex executable in PATH" if not command_available?

    ## TODO: determine exact command
    cmd = "pdf2htmlex #{source} #{target}"
    `#{cmd}`

    ## TODO: Grab error message from pdf2htmlex and raise a better error
    raise IOError, "Could not convert #{source}" if $?.exitstatus != 0
  end

  private

  def self.command_available?
    which("pdf2htmlex") || which("pdf2htmlEX")
  end

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