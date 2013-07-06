require 'assets/parsers/itunes.rb'
require 'cjutils/path'

require 'scanner_job'

class ITunesLibraryScannerJob < ScannerJob
  extend CJUtils::Path
  
  def perform
    halt = false
    Signal.trap('TERM') { halt = true }
    
    raise JobError, 'Source is no longer in database' if source.nil?

    # add/update tracks
    get_uris.each do |uri|
      handle_uri(uri)
      exit if halt
    end
    
    # remove tracks from database that are no longer in iTunes library
    source.tracks.all.each do |track|
      next if uris.include?(URI::File.new_with_path(track.location))
      track.destroy
      exit if halt
    end
  end

  def get_uris
    uris = []
    ITunesLibrary.parse(source.location) do |track_info|
      track_info_normalized = normalize_track_info(track_info)
      
      if track_info_normalized.has_key?(:location)
        uris << URI(track_info_normalized[:location])
      end
    end

    uris
  end 

  def normalize_track_info(track_info)
    track_info_normalized = {}
    track_info.each do |key, value|
      track_info_normalized[self.class.normalize(key)] = value
    end

    track_info_normalized
  end

  def handle_uri(uri)
    fpath = self.class.uri_to_path(uri)
    if File.exists?(fpath)
      t = get_track_for_file_path(fpath)
      unless t.sources.include?(source)
        t.sources << source
        t.save
      end
    end
  end

  def self.normalize(str)
    norm = str.downcase
    norm.gsub!(' ', '_')
    norm.to_sym
  end
end
