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

  def to_hash
    Hash.new.tap do |hash|
      [:uuid, :name, :name_normalized].each { |k| hash[k] = send(k) }
    end
  end

  def to_json(obj)
    JSON.dump(genre: to_hash)
  end
end
