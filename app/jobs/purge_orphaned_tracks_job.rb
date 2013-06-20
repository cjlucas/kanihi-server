require 'base_job'

class PurgeOrphanedTracksJob < BaseJob
  def perform
    Track.all.each do |track|
      # delete track if it no longer has any sources linked to it
      if track.sources.empty?
        track.destroy
        logger.info("Deleting #{track.uri} from database.")
      end
    end
  end
end
