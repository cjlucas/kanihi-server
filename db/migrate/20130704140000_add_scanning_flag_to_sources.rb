class AddScanningFlagToSources < ActiveRecord::Migration
  def change
    change_table :sources do |t|
      t.boolean :scanning, :default => false
    end
  end
end
