require 'assets/parsers/itunes.rb'
require 'utils/path'

require 'base_job'

class ITunesLibraryParserJob < BaseJob
  extend MusicServer::Utils::Path
  def initialize(source)
    @src = source
  end

  # start delayed_job hooks
  
  def perform
    uris = get_uris
    # remove tracks from database that are no longer in iTunes library
    @src.tracks.all.each do |track|
      next if uris.include?(URI::File.new_with_path(track.location))
      logger.info("Deleting #{track.uri} from database")
      track.destroy
    end

    # add/update tracks
    uris.each { |uri| handle_uri(uri) }

    update_source
  end

  # end delayed_job hooks
 
  def get_uris
    uris = []
    ITunesLibrary.parse(@src.location) do |track_info|
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
      t = Track.track_for_file_path(fpath)
      unless t.sources.include?(@src)
        t.sources << @src
        t.save
      end
      
      now = Time.now
      if now - t.created_at < 5
        logger.info("Added #{fpath}")
      elsif now - t.updated_at < 5
        logger.info("Updated #{fpath}")
      end

    else
      logger.info("#{fpath} doesn't exist. Skipping.")
    end
  end

  def self.normalize(str)
    norm = str.downcase
    norm.gsub!(' ', '_')
    norm.to_sym
  end
end
