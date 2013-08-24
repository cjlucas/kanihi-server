require 'base_job'

class ScannerJob < BaseJob
  alias :super_after :after

  EASYTAG_ATTRIBUTES = [
    :album,
    :album_sort_order,
    :composer,
    :compilation?,
    :date,
    :disc_subtitle,
    :duration,
    :genre,
    :group,
    :lyrics,
    :mood,
    :original_date,
    :subtitle,
    :artist,
    :artist_sort_order,
    :title,
    :title_sort_order,
    :comment,
    :album_artist,
    :album_artist_sort_order,
    :album_art,
    :track_num,
    :disc_num
    ].freeze

  def self.job_for_source(source)
    case source.source_type
    when Source::Type::DIRECTORY
      DirectoryScannerJob.new(source)
    when Source::Type::ITUNES_LIBRARY_XML_FILE
      ITunesLibraryScannerJob.new(source)
    end
  end
  
  def initialize(source)
    @source_id = source.id
  end

  def priority
    Priority::HIGH
  end

  def source
    @source ||= Source.where(id: @source_id).first
  end

  def success(job)
    source.last_scanned_at = Time.now
  end

  def after(job)
    source.scanning = false
    source.save

    super_after(job)
  end

  #
  # Helper method that falls back to slow track lookup if create fails
  #
  def get_track_for_file_path(fpath)
    t = nil
    easytag_attrs = {}
    force_update = false

    t = Track.track_for_file_path(fpath)

    # lookup by filesystem id
    if t.nil?
      fsid = generate_filesystem_id(File.stat(fpath))
      t = Track.where(filesystem_id: fsid).first
      force_update = true
    end

    # lookup by attributes
    if t.nil?
      handle_easytag_exception do 
        easytag_attrs = et_attrs_for_file_path(fpath)
      end
      return nil if easytag_attrs.empty?

      attribs = track_attributes_for_et_attrs(easytag_attrs)
      t = Track.track_for_attributes(attribs)
      force_update = true
    end

    # create track if one doesn't already exist
    t ||= Track.new_with_location(fpath)

    if force_update || !t.persisted? || t.file_modified?
      puts "#{t.location}: updating attributes" if $DEBUG

      if easytag_attrs.empty?
        easytag_attrs = et_attrs_for_file_path(fpath)
      end

      update_models(t, easytag_attrs)
    end

    t 
  end

  def handle_easytag_exception(&block)
    begin
      block.call
    rescue EasyTag::EasyTagFileUnsupportedError => e
      puts 'ERROR: file unsupported'
      puts e
    rescue => e
      puts 'ERROR: unknown'
      puts e
    end
  end

  def et_attrs_for_file_path(fpath)
    attributes = {}

    EasyTag::File.open(fpath) do |et|
      EASYTAG_ATTRIBUTES.each do |attr|
        attributes[attr] = attrib_or_nil(et.send(attr))
      end
    end

    attributes
  end

  def track_attributes_for_et_attrs(et_attrs)
    Hash.new.tap do |track_attrs|
      [
        :comment, :composer, :date, :original_date, :duration, :group,
        :lyrics, :mood, :subtitle
      ].each { |attr| track_attrs[attr] = et_attrs[attr] }

      track_attrs[:name] = et_attrs.fetch(:title)
      track_attrs[:num]  = et_attrs.fetch(:track_num).first
    end
  end

  def update_models(track, et_attrs)
    track_artist = nil
    album_artist = nil
    album = nil
    disc = nil
    genre = nil

    # album artist
    album_artist_attrs = Hash.new.tap do |attrs|
      attrs[:name] = et_attrs.fetch(:album_artist) || et_attrs.fetch(:artist)
      attrs[:sort_name] = et_attrs.fetch(:album_artist_sort_order) ||
        et_attrs.fetch(:album_artist_sort_order)
    end

    album_artist = AlbumArtist.unique_record_with_attributes(album_artist_attrs)
    
    # album
    album_attrs = Hash.new.tap do |attrs|
      attrs[:name] = et_attrs.fetch(:album)
      attrs[:album_artist] = album_artist
    end

    album = Album.unique_record_with_attributes(album_attrs)

    # disc
    disc_attrs = Hash.new.tap do |attrs|
      attrs[:num] = et_attrs.fetch(:disc_num).first
      attrs[:subtitle] = et_attrs.fetch(:disc_subtitle)
      attrs[:total_tracks] = et_attrs.fetch(:track_num).last
      attrs[:album] = album
    end

    disc = Disc.unique_record_with_attributes(disc_attrs)

    # track artist
    track_artist_attrs = Hash.new.tap do |attrs|
      attrs[:name] = et_attrs.fetch(:artist)
      attrs[:sort_name] = et_attrs.fetch(:artist_sort_order)
    end

    track_artist = TrackArtist.unique_record_with_attributes(track_artist_attrs)

    # genre
    genre_attrs = Hash.new.tap do |attrs|
      attrs[:name] = et_attrs[:genre] unless et_attrs.fetch(:genre).nil?
    end

    unless genre_attrs.empty?
      genre = Genre.unique_record_with_attributes(genre_attrs)
    end

    # track
    fstat = File.stat(track.location)
    track.size  = fstat.size
    track.mtime = fstat.mtime
    track.filesystem_id = generate_filesystem_id(fstat)

    track_attrs = track_attributes_for_et_attrs(et_attrs)
    track.update_attributes(track_attrs)
    track.genre = genre
    track.track_artist = track_artist
    track.disc = disc

    # images
    et_attrs[:album_art].each do |et_img|
      img = Image.image_for_data(et_img.data)
      track.images << img unless track.images.include?(img)
    end

    return {
      track: track, 
      genre: genre, 
      album_artist: album_artist,
      track_artist: track_artist, 
      disc: disc
    }
  end

  def generate_filesystem_id(stat)
    stat.dev.to_i * stat.ino.to_i
  end

  def attrib_or_fallback(attrib, fallback)
    klass = attrib.class
    
    case
    when klass == String
      attrib.empty? ? fallback : attrib
    when klass == Fixnum
      attrib == 0 ? fallback : attrib
    end
  end

  def attrib_or_nil(attrib)
    klass = attrib.class

    case
    when klass == String
      attrib.empty? ? nil : attrib
    else
      attrib
    end
  end
end
