class AddScanIntervalToSources < ActiveRecord::Migration
  def change
    change_table :sources do |t|
      t.integer :scan_interval, :default => 86400
    end
  end

end
