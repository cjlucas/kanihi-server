class Genre < UniqueRecord
  attr_accessible :name
  attr_protected  :name_normalized

  has_many :tracks

  def self.unique_relation_with_attributes(attributes)
    name_normalized = normalize(attributes.fetch(:name))
    where('name_normalized = ?', name_normalized)
  end

  def name=(name)
    write_attribute(:name, name)
    self.name_normalized = self.class.normalize(name)
  end
end
