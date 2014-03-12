class TrackArtist < UniqueRecord
  attr_accessible :name
  attr_protected :name_normalized
  attr_accessible :sort_name

  has_many :tracks

  def self.unique_relation_with_attributes(attributes)
    where('name_normalized = ?', normalize(attributes[:name]))
  end
  
  def name=(name)
    write_attribute(:name, name)
    self.name_normalized = self.class.normalize(name)
  end

  def to_hash
    Hash.new.tap do |hash|
      [:uuid, :name, :name_normalized, :sort_name].each { |k| hash[k] = send(k) }
    end
  end

  def to_json(obj)
    JSON.dump(track_artist: to_hash)
  end
end

