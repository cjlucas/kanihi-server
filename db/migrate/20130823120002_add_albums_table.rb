class AddAlbumsTable < ActiveRecord::Migration
  def change
    create_table :albums do |t|
      t.string :name
      t.string :uuid,       null: false

      t.belongs_to :album_artist
      t.timestamps
    end
  end
end

