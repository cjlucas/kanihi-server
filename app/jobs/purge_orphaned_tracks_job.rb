require 'base_job'

class PurgeOrphanedTracksJob < BaseJob
  include DestroyTracksMixin
  def perform
    destroy_tracks do |track_uuids|
      Track.find_each { |track| track_uuids << track.uuid if track.sources.empty? }
    end
  end

  def priority
    Priority::LOW
  end
end
