require "kristin/version"
require 'open-uri'
require "net/http"

module Kristin
  def self.convert(source, target)
    raise IOError, "Can't find pdf2htmlex executable in PATH" if not command_available?
    src = determine_source(source)
    cmd = "#{pdf2htmlex_command} #{src} #{target}"
    
    `#{cmd}`
    ## TODO: Grab error message from pdf2htmlex and raise a better error
    raise IOError, "Could not convert #{src}" if $?.exitstatus != 0
  end

  private

  def self.command_available?
    which("pdf2htmlex") || which("pdf2htmlEX")
  end

  def self.pdf2htmlex_command
    cmd = nil
    if which("pdf2htmlex")
      cmd = "pdf2htmlex"
    elsif which("pdf2htmlEX")
      cmd = "pdf2htmlEX"
    end

    cmd
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

  def self.random_source_name
    rand(16**16).to_s(16)
  end

  def self.download_file(source)
    tmp_file = "/tmp/#{random_source_name}.pdf"
    File.open(tmp_file, "wb") do |saved_file|
      open(source, 'rb') do |read_file|
        saved_file.write(read_file.read)
      end
    end

    tmp_file
  end

  def self.determine_source(source)
    is_file = File.exists?(source) && !File.directory?(source)
    is_http = URI(source).scheme == "http" && Net::HTTP.get_response(URI(source)).is_a?(Net::HTTPSuccess)
    is_https = URI(source).scheme == "https" && Net::HTTP.get_response(URI(source)).is_a?(Net::HTTPSuccess)
    raise IOError, "Source (#{source}) is neither a file nor an URL." unless is_file || is_http || is_https

    if is_file
      source
    else
      download_file(source)
    end
  end
end