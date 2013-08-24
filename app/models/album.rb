class Album < UniqueRecord
  attr_accessible :name
  attr_protected  :name_normalized
  attr_accessible :total_discs
  attr_accessible :album_artist
 
  belongs_to :album_artist 
  has_many :discs

  def self.unique_relation_with_attributes(attributes)
    name = attributes[:name]
    album_artist = attributes[:album_artist]

    where('name = ? AND album_artist_id = ?', name, album_artist)
  end
  
  def name=(name)
    write_attribute(:name, name)
    self.name_normalized = self.class.normalize(name)
  end
end
