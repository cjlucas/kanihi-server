require 'assets/parsers/itunes.rb'

require 'base_job'

class ITunesLibraryParserJob < BaseJob
  def initialize(source)
    @src = source
  end

  # start delayed_job hooks
  
  def perform
    ITunesLibrary.parse(@src.location) do |track_info| 
      handle_track_info(track_info)
    end

    update_source
  end

  # end delayed_job hooks
  
  def build_track_info_normalized
    track_info_normalized = {}
    @track_info.each do |key, value|
      track_info_normalized[self.class.normalize(key)] = value
    end

    track_info_normalized
  end

  def handle_track_info(track_info)
    @track_info = track_info
    @track_info_normalized = build_track_info_normalized
    
    if @track_info_normalized.has_key?(:location)
      uri = URI(@track_info_normalized[:location])
      fpath = URI.unescape(uri.path)
      if File.exists?(fpath)
        t = Track.track_for_file_path(fpath)
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
