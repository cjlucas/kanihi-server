class AddTotalDiscsColumnToAlbums < ActiveRecord::Migration
  def change
    change_table :albums do |t|
      t.integer :total_discs
    end
  end
end

