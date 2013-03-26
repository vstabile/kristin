require "kristin/version"

module Kristin
  def self.convert(source, target)
    unless File.exists?(source) 
      raise IOError, "Source file (#{source}) does not exist."
    end 
  end
end