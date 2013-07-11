class AddUpdatedAtIndexToTracks < ActiveRecord::Migration
  def change
    add_index :tracks, :updated_at
  end
end
