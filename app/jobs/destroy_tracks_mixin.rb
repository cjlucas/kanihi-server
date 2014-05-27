module DestroyTracksMixin
  def destroy_tracks(&block)
    track_uuids = []
    block.call(track_uuids)

    Track.where(uuid: track_uuids).destroy_all
    ActiveRecord::Base.transaction do
      track_uuids.each { |track_uuid| DeletedTrack.new(uuid: track_uuid).save }
    end
  end
end