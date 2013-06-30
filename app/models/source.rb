#
# Use the Source.new_with_type entry point
#
class Source < ActiveRecord::Base
  extend CJUtils::Path
  class Type
    DIRECTORY               = 0
    ITUNES_LIBRARY_XML_FILE = 1
  end

  class SourceNotFoundError < Exception; end

  attr_protected :last_scanned_at, :location, :source_type, :scan_interval
  has_and_belongs_to_many :tracks

  validates :location, uniqueness: true

  def exists?
    File.exists?(location)
  end

  def self.new_with_source_type(location, source_type)
    src             = self.new
    src.location    = sanitize_path(location)
    src.source_type = source_type
    raise SourceNotFoundError unless src.exists?
    
    src
  end
end
