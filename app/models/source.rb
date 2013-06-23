#
# Use the Source.new_with_type entry point
#
class Source < ActiveRecord::Base
  class Type
    DIRECTORY               = 0
    ITUNES_LIBRARY_XML_FILE = 1
  end

  class SourceNotFoundError < Exception; end

  attr_protected :last_scanned_at, :location, :source_type, :scan_interval

  has_and_belongs_to_many :tracks

  def exists?
    File.exists?(self.location)
  end

  def self.new_with_source_type(location, source_type)
    src             = self.new
    src.location    = location
    src.source_type = source_type
    raise SourceNotFoundError unless src.exists?
    
    src
  end
end
