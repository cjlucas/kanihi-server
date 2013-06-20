class CreateSourcesTracksJoinTable < ActiveRecord::Migration
  def change
    create_table :sources_tracks, id: false do |t|
      t.integer :source_id
      t.integer :track_id
    end
  end
end
