class AddIndexesToImagesTracksTable < ActiveRecord::Migration
  def change
    add_index :images_tracks, :image_id
    add_index :images_tracks, :track_id
  end
end
