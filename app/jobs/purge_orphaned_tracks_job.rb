require 'base_job'

class PurgeOrphanedTracksJob < BaseJob
  def perform
    Track.all.each do |track|
      track.destroy if track.sources.empty?
    end
  end

  def priority
    Priority::LOW
  end
end
