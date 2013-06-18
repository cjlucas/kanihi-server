class CreateTracks < ActiveRecord::Migration
  def change
    create_table :tracks do |t|
      t.string :track_name
      t.string :subtitle
      t.integer :track_num
      t.integer :track_total
      t.string :track_artist
      t.string :track_artist_sort_order
      t.string :album_artist
      t.string :album_artist_sort_order
      t.string :album_name
      t.string :genre
      t.datetime :date
      t.datetime :original_date
      t.integer :disc_num
      t.integer :disc_total
      t.string :disc_subtitle
      t.string :group
      t.string :lyrics
      t.string :composer
      t.string :mood
      t.boolean :compilation
      t.string :comment
      t.integer :duration
      t.timestamp :mtime
      t.integer :size
      t.string :uri

      t.timestamps

    end
      
      add_index :tracks, :uri
  end
end
