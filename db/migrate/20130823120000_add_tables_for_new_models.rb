class AddTablesForNewModels < ActiveRecord::Migration
  def change
    create_table :track_artists do |t|
      t.string :name,       null: false
      t.string :sort_name
      t.string :uuid,       null: false
      
      #t.has_many :tracks
      t.belongs_to :track
      t.timestamps
    end

    create_table :album_artists do |t|
      t.string :name,       null: false
      t.string :sort_name
      t.string :uuid,       null: false

      t.timestamps
    end

    create_table :discs do |t|
      t.integer :num
      t.string  :subtitle
      t.integer :total_tracks
      t.string  :uuid,           null: false

      t.belongs_to :album
      t.timestamps
    end

    create_table :genres do |t|
      t.string :name
      t.string :uuid,      null: false

      #t.has_many :tracks
      t.belongs_to :track
      t.timestamps
    end

    remove_columns :tracks,  :album_artist,
                            :album_artist_sort_order,
                            :album_name,
                            :disc_num,
                            :disc_subtitle,
                            :disc_total,
                            :genre,
                            :track_artist,
                            :track_artist_sort_order,
                            :track_total

    rename_column :tracks, :track_name, :name
    rename_column :tracks, :track_num, :num

    change_table :tracks do |t|
      t.belongs_to :disc
    end
  end
end
