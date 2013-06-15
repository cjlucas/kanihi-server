class CreateTrackImageJoinTable < ActiveRecord::Migration
  def change
    create_table :images_tracks, id: false do |t|
      t.integer :track_id
      t.integer :image_id
    end
  end
end

