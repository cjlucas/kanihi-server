class UniqueRecord < ActiveRecord::Base
  self.abstract_class = true

  attr_accessible :uuid
  before_validation :ensure_uuid_exists
  
  def self.unique_record_with_attributes(attributes)
    record = unique_relation_with_attributes(attributes).first
    record ||= self.new

    record.assign_attributes(attributes)
    record.save if record.changed?

    record
  end
  
  protected
  
  def self.generate_uuid
    UUIDTools::UUID.random_create.to_s.downcase
  end

  def ensure_uuid_exists
    self.uuid = self.class.generate_uuid if self.uuid.nil?
  end

  # Returns an ActiveRecord::Relation that, when executed,
  # should return at most one result
  def self.unique_relation_with_attributes(attributes)
    raise NotImplementedError
  end

  def self.normalize(string)
    ActiveSupport::Inflector.transliterate(string).downcase.strip
  end
end
