require 'cjutils/path'

class Track < UniqueRecord
  extend CJUtils::Path
  before_destroy :cleanup_dependents
  
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

  def cleanup_dependents
    self.disc.destroy if self.disc.tracks.count == 1
    self.genre.destroy if self.genre.tracks.count == 1
    self.track_artist.destroy if self.track_artist.tracks.count == 1
  end

  def file_modified?
    (mtime || Time.new(1960)) < File.stat(location).mtime
  end

  def location=(location)
    write_attribute(:location, self.class.sanitize_path(location))
  end

  def to_hash
    Hash.new.tap do |hash|
      [
          :uuid,
          :comment,
          :compilation,
          :composer,
          :date,
          :duration,
          :group,
          :lyrics,
          :mood,
          :original_date,
          :subtitle,
          :name,
          :num,
      ].each { |k| hash[k] = send(k) }

      hash[:disc] = disc.to_hash
      hash[:genre] = genre.to_hash
      hash[:track_artist] = track_artist.to_hash
      hash[:images] = images.to_a.collect { |img| img.to_hash }
    end
  end

  def to_json(obj)
    JSON.dump(track: to_hash)
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
