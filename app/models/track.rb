require 'cjutils/path'

class Track < ActiveRecord::Base
  extend CJUtils::Path
  attr_accessible :album_artist
  attr_accessible :album_artist_sort_order
  attr_accessible :album_name
  attr_accessible :comment
  attr_accessible :compilation
  attr_accessible :composer
  attr_accessible :date
  attr_accessible :disc_num
  attr_accessible :disc_subtitle
  attr_accessible :disc_total
  attr_accessible :duration
  attr_accessible :genre
  attr_accessible :group
  attr_accessible :lyrics
  attr_accessible :mood
  attr_accessible :mtime
  attr_accessible :original_date
  attr_accessible :size
  attr_accessible :subtitle
  attr_accessible :track_artist
  attr_accessible :track_artist_sort_order
  attr_accessible :track_name
  attr_accessible :track_num
  attr_accessible :track_total
  attr_accessible :location
  attr_accessible :images
  attr_accessible :filesystem_id

  has_and_belongs_to_many :images
  has_and_belongs_to_many :sources

  before_validation :ensure_uuid_exists

  validates_presence_of :location, :uuid, :filesystem_id
  validates_uniqueness_of :location, :uuid

  def ensure_uuid_exists
    self.uuid = self.class.generate_uuid if self.uuid.nil?
  end

  def file_modified?
    (mtime || Time.new(1960)) < File.stat(location).mtime
  end

  def location=(location)
    write_attribute(:location, self.class.sanitize_path(location))
  end

  def self.generate_uuid
    UUIDTools::UUID.random_create.to_s.downcase
  end

  def self.track_for_file_path(fpath)
    fpath = sanitize_path(fpath)

    where(location: fpath).first
  end

  def self.track_for_attribs(attribs)
    attribs = attribs.dup
    ignore_attribs = [:mtime, :images, :location, :date, :original_date]
    ignore_attribs.each { |attr| attribs.delete(attr) }

    where(attribs).first
  end
end
