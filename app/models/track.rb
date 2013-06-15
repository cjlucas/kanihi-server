class Track < ActiveRecord::Base
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
  attr_accessible :uri
  attr_accessible :images

  has_and_belongs_to_many :images

  validates :uri, \
    :uniqueness   => { :case_sensitive => false }, \
    :allow_nil    => false, \
    :allow_blank  => false

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

  def file_modified?
    path = URI.unescape(URI(uri).path)
    (mtime || 0) < File.stat(path).mtime
  end

  def self.attributes_for_file_path(fpath)
    attribs = {}
    et = EasyTag::File.new(fpath)
    
    attribs[:uri] = uri_for_path(fpath).to_s

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
    et.album_art.each do |image|
      attribs[:images] << Image.image_for_data(image.data)
    end

    # size, mtime
    fstat = File.stat(fpath)
    attribs[:size] = fstat.size
    attribs[:mtime] = fstat.mtime
    
    attribs.each do |attrib, value|
      attribs[attrib] = attrib_or_nil(value)
    end

    attribs
  end

  def self.track_for_file_path(fpath, force_update = false)
    uri = uri_for_path(fpath)
    t = Track.where(uri: uri.to_s).first_or_create

    if force_update || (t == Track.last) || t.file_modified?
      puts 'updating attributes' if Rails.env.test?
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

  def self.uri_for_path(path)
    uri_path = URI.escape(path)
    uri_path = URI.escape(uri_path, '^[]\,\'\"')
    URI("file://#{uri_path}")
  end
end
