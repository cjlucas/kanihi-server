class Disc < UniqueRecord
  attr_accessible :num
  attr_accessible :subtitle
  attr_accessible :total_tracks
  attr_accessible :album

  belongs_to :album

  def self.unique_relation_with_attributes(attributes)
    num = attributes[:num]
    album = attributes[:album]

    where('num = ? AND album_id = ?', num, album)
  end
end
