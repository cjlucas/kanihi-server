class Disc < UniqueRecord
  before_destroy :cleanup_dependents
  
  attr_accessible :num
  attr_accessible :subtitle
  attr_accessible :total_tracks
  attr_accessible :album

  belongs_to :album
  has_many :tracks

  def self.unique_relation_with_attributes(attributes)
    num = attributes[:num]
    album = attributes[:album]

    where('num = ? AND album_id = ?', num, album)
  end

  def cleanup_dependents
    self.album.destroy if self.album.discs.count == 1
  end
end
