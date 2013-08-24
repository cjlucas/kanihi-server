require 'cjutils/path'

class Track < UniqueRecord
  extend CJUtils::Path
  attr_accessible :comment
  attr_accessible :compilation
  attr_accessible :composer
  attr_accessible :date
  attr_accessible :duration
  attr_accessible :group
  attr_accessible :lyrics
  attr_accessible :mood
  attr_accessible :mtime
  attr_accessible :original_date
  attr_accessible :size
  attr_accessible :subtitle
  attr_accessible :name
  attr_accessible :num
  attr_accessible :location
  attr_accessible :filesystem_id

  has_and_belongs_to_many :images
  has_and_belongs_to_many :sources
  belongs_to :disc
  belongs_to :genre
  belongs_to :track_artist

  validates_presence_of :location, :uuid, :filesystem_id
  validates_uniqueness_of :location, :uuid

  def file_modified?
    (mtime || Time.new(1960)) < File.stat(location).mtime
  end

  def location=(location)
    write_attribute(:location, self.class.sanitize_path(location))
  end

  def self.track_for_file_path(fpath)
    fpath = sanitize_path(fpath)

    where(location: fpath).first
  end

  def self.track_for_attributes(attribs)
    attribs = attribs.dup
    ignore_attribs = [:mtime, :images, :location, :date, :original_date]
    ignore_attribs.each { |attr| attribs.delete(attr) }

    where(attribs).first
  end

  def self.new_with_location(location)
    new.tap do |track|
      track.location = sanitize_path(location)
    end
  end
end
