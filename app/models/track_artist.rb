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
end

