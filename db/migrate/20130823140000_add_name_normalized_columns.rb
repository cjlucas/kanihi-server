class AddNameNormalizedColumns < ActiveRecord::Migration
  def change
    [:albums, :album_artists, :track_artists, :genres].each do |t|
      add_column t, :name_normalized, :string
    end
  end
end
