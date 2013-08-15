class AddIndexesToSourcesTracksTable < ActiveRecord::Migration
  def change
    add_index :sources_tracks, :source_id
    add_index :sources_tracks, :track_id
  end
end
