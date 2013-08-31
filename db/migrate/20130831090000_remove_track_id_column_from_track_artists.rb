class RemoveTrackIdColumnFromTrackArtists < ActiveRecord::Migration
  def change
    remove_column :track_artists, :track_id
  end
end
