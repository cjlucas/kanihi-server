class CreateSources < ActiveRecord::Migration
  def change
    create_table :sources do |t|
      t.string :location
      t.integer :source_type
      t.timestamp :last_scanned_at

      t.timestamps
    end
  end
end
