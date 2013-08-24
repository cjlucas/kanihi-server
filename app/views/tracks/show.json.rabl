object @track

track_attributes = [
  :uuid,
  :name,
  :subtitle,
  :num,
  :date,
  :original_date,
  :group,
  :lyrics,
  :composer,
  :mood,
  :compilation,
  :comment,
  :duration,
]

attributes(*track_attributes)

child :track_artist do
  attributes :uuid, :name, :sort_name
end

child :genre do
  attributes :uuid, :name
end

child :disc do
  attributes :uuid, :num, :subtitle, :total_tracks

  child :album do
    attributes :uuid, :name, :total_discs

    child :album_artist do
      attributes :uuid, :name, :sort_name
    end
  end
end

child :images do
  attributes :checksum, :type, :description
end
