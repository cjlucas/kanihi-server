object @track

track_attributes = [
  :uuid,
  :track_name,
  :subtitle,
  :track_num,
  :track_total,
  :track_artist,
  :track_artist_sort_order,
  :album_artist,
  :album_artist_sort_order,
  :album_name,
  :genre,
  :date,
  :original_date,
  :disc_num,
  :disc_total,
  :disc_subtitle,
  :group,
  :lyrics,
  :composer,
  :mood,
  :compilation,
  :comment,
  :duration,
]

attributes(*track_attributes)

child :images do
  attributes :checksum, :type, :description
end
