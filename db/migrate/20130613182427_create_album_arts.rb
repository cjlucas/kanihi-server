class CreateAlbumArts < ActiveRecord::Migration
  def change
    create_table :album_arts do |t|
      t.binary :data
      t.string :checksum
      t.integer :size

      t.timestamps
    end
  end
end
