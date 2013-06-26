class CreateSettings < ActiveRecord::Migration
  def change
    create_table :settings do |t|
      t.string   :keyname,       :null => false, :limit => 64
      t.text     :value
      t.string   :value_format,  :limit => 64,   :default => "string"
      t.string   :name,          :limit => 64
      t.string   :description,   :limit => 512
      t.timestamps
    end
  end
end
