class FixRelationshipsForNewModels < ActiveRecord::Migration
  def change
    remove_column :genres, :track_id

    change_table :tracks do |t|
      t.belongs_to :genre
      t.belongs_to :track_artist
    end
  end
end

