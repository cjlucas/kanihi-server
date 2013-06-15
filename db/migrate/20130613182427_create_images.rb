class CreateImages < ActiveRecord::Migration
  def change
    create_table :images do |t|
      t.string :type
      t.string :description
      t.string :checksum
      t.integer :size

      t.timestamps
    end
  end
end
