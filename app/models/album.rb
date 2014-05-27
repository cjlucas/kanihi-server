class Album < UniqueRecord
  before_destroy :cleanup_dependents

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

  def cleanup_dependents
    album_artist.destroy if !album_artist.nil? && album_artist.albums.count == 1
  end
  
  def name=(name)
    write_attribute(:name, name)
    self.name_normalized = self.class.normalize(name)
  end

  def to_hash
    Hash.new.tap do |hash|
      [:uuid, :name, :name_normalized, :total_discs, :album_artist].each { |k| hash[k] = send(k) }

      hash[:album_artist] = album_artist.to_hash
    end
  end

  def to_json(obj)
    JSON.dump(album: to_hash)
  end

end
