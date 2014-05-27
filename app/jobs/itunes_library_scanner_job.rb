require 'assets/parsers/itunes.rb'
require 'cjutils/path'

require 'scanner_job'

class ITunesLibraryScannerJob < ScannerJob
  extend CJUtils::Path
  
  def perform
    raise JobError, 'Source is no longer in database' if source.nil?

    puts 'Parsing XML file'
    uris = get_uris

    puts 'Adding/updating tracks'
    # add/update tracks
    uris.each do |uri|
      handle_uri(uri)
    end

    # remove tracks from database that are no longer in iTunes library
    puts 'Deleting tracks'
    #start = Time.now
    paths = []
    uris.each { |uri| paths << self.class.uri_to_path(uri) }

    destroy_tracks do |track_uuids|
      Track.where('location NOT IN (?)', paths).each { track_uuids << track.uuid }
    end

    #puts "Execution Time: #{Time.now - start}"
    #source.tracks.all.each do |track|
    #start = Time.now
    #uris.include?(URI::File.new_with_path(track.location))
    #puts "Execution Time: #{Time.now - start}"
    #next if uris.include?(URI::File.new_with_path(track.location))
    #track.destroy
    #exit if halt
    #end
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
      return if t.nil?

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
