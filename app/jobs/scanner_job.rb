require 'base_job'

class ScannerJob < BaseJob
  alias :super_after :after

  # simple mappings
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
    attribs = {}
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
      handle_easytag_exception { attribs = attributes_for_file_path(fpath) }
      return nil if attribs.empty?

      t = Track.track_for_attributes(attribs)
      force_update = true
    end

    # create track if one doesn't already exist
    t ||= Track.new

    if force_update || !t.persisted? || t.file_modified?
      puts "#{t.location}: updating attributes" if $DEBUG
      attribs = attributes_for_file_path(fpath) if attribs.empty?
      t.update_attributes(attribs)
      t.save
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

  def attributes_for_file_path(fpath)
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
      attribs[:filesystem_id] = generate_filesystem_id(fstat)

      attribs.each do |attrib, value|
        attribs[attrib] = attrib_or_nil(value)
      end

    end

    attribs
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
