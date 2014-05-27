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
    album.destroy if !album.nil? && album.discs.count == 1
  end

  def to_hash
    Hash.new.tap do |hash|
      [:uuid, :num, :subtitle, :total_tracks, :album].each { |k| hash[k] = send(k) }

      hash[:album] = album.to_hash
    end
  end

  def to_json(obj)
    JSON.dump(disc: to_hash)
  end
end