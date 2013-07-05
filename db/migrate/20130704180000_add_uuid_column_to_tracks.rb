class AddUuidColumnToTracks < ActiveRecord::Migration
  def change
    add_column :tracks, :uuid, :string
    add_index :tracks, :uuid, :unique => true, :name => :tracks_uuid_idx
  end
end

