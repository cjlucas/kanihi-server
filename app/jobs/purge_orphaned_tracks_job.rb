require 'base_job'

class PurgeOrphanedTracksJob < BaseJob
  def perform
    Track.find_each do |track|
      track.destroy if track.sources.empty?
    end
  end

  def priority
    Priority::LOW
  end
end
