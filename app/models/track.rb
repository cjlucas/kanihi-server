class Track < ActiveRecord::Base
  attr_accessible :album_art_id
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

  validates :uri, :uniqueness => { :case_sensitive => false }

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
  }   

  def self.new_with_file_path(fpath)
    t = self.new

    et = EasyTag::File.new(fpath)
    
    t.uri = uri_for_path(fpath).to_s

    EASYTAG_ATTRIB_MAP.each do |key, value|
      t.send("#{key}=", et.send(value))
    end

    # fallback: track_artist
    t.album_artist = attrib_with_fallback(et.album_artist, et.artist)

    # fallback to Track.album_artist
    t.album_artist_sort_order = attrib_with_fallback(
      et.album_artist_sort_order,
      t.album_artist)

    # track num/total
    t.track_num, t.track_total = et.track_num

    # disc num/total
    t.disc_num, t.disc_total = et.disc_num

    # size, mtime
    fstat = File.stat(fpath)
    t.size = fstat.size
    t.mtime = fstat.mtime
    
    # TODO: move this somewhere else
    t.attribute_names.each do |attrib|
      t.send("#{attrib}=", attrib_or_nil(t.send(attrib)))
    end

    t
  end

  def self.attrib_with_fallback(attrib, fallback)
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
    path = URI.escape(path)
    uri = URI(path)
    uri.scheme = 'file'
    uri
  end
end
