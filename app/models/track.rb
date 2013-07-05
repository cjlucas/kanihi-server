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

  has_and_belongs_to_many :images
  has_and_belongs_to_many :sources

  before_validation :ensure_uuid_exists

  validates_presence_of :location, :uuid
  validates_uniqueness_of :location, :uuid

  # simple 
  EASYTAG_ATTRIB_MAP = {
    :album_name               => :album,
    :composer                 => :composer,
    :compilation              => :compilation?,
    :date                     => :date,
    :disc_subtitle            => :disc_subtitle,
    :duration                 => :duration,
    :genre                    => :genre,
    :group                    => :group,
    :lyrics                   => :lyrics,
    :mood                     => :mood,
    :original_date            => :original_date,
    :subtitle                 => :subtitle,
    :track_artist             => :artist,
    :track_artist_sort_order  => :artist_sort_order,
    :track_name               => :title,
    :comment                  => :comment
  }   

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

  def self.attributes_for_file_path(fpath)
    attribs = {}

    EasyTag::File.open(fpath) do |et|
      attribs[:location] = File.absolute_path(fpath)

      EASYTAG_ATTRIB_MAP.each do |key, value|
        attribs[key] = et.send(value)
      end

      # fallback: track_artist
      attribs[:album_artist] = attrib_or_fallback(et.album_artist, et.artist)

      # fallback to track_artist_sort_order
      attribs[:album_artist_sort_order] = attrib_or_fallback(
        et.album_artist_sort_order,
        attribs[:track_artist_sort_order])

      # track num/total
      attribs[:track_num], attribs[:track_total] = et.track_num

      # disc num/total
      attribs[:disc_num], attribs[:disc_total] = et.disc_num

      # images
      attribs[:images] = []
      et.album_art.each do |et_img|
        img = Image.image_for_data(et_img.data)
        attribs[:images] << img unless attribs[:images].include?(img)
      end

      # size, mtime
      fstat = File.stat(fpath)
      attribs[:size] = fstat.size
      attribs[:mtime] = fstat.mtime

      attribs.each do |attrib, value|
        attribs[attrib] = attrib_or_nil(value)
      end

    end

    attribs
  end

  def self.track_for_file_path(fpath, force_update = false)
    fpath = File.absolute_path(fpath)
    t = Track.where(location: fpath).first_or_create

    if force_update || (Time.now - t.created_at < 5) || t.file_modified?
      puts "#{t.location}: updating attributes" if $DEBUG
      t.update_attributes(attributes_for_file_path(fpath))
      t.save
    end

    t
  end

  def self.attrib_or_fallback(attrib, fallback)
    klass = attrib.class
    
    case
    when klass == String
      attrib.empty? ? fallback : attrib
    when klass == Fixnum
      attrib == 0 ? fallback : attrib
    end
  end

  def self.attrib_or_nil(attrib)
    klass = attrib.class

    case
    when klass == String
      attrib.empty? ? nil : attrib
    else
      attrib
    end
  end
end
