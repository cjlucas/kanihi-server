class AddFilesystemIdColumnToTracks < ActiveRecord::Migration
  def up
    add_column :tracks, :filesystem_id, :integer

    Track.all.each do |track|
      stat = File.stat(track.location) rescue nil
      track.filesystem_id = Track.generate_filesystem_id(stat) unless stat.nil?
      track.save
    end
  end

  def down
    remove_column :tracks, :filesystem_id
  end
end
