class AddDeletedTracksTable < ActiveRecord::Migration
  def change
    create_table :deleted_tracks do |t|
      t.string :uuid
      t.timestamps
    end

    add_index :deleted_tracks, :created_at
  end
end