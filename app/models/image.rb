class Image < ActiveRecord::Base
  attr_accessible :type
  attr_accessible :description
  attr_accessible :checksum
  attr_accessible :size

  has_and_belongs_to_many :tracks

  # unique by checksum and size
  validates_uniqueness_of :checksum, scope: :size

  def self.image_for_data(data)
    attribs = attributes_for_data(data)
    img = Image.where(
      checksum: attribs[:checksum],
      size: attribs[:size],
    ).first_or_create

    # if just created
    img.update_attributes(attribs) if img == Image.last

    img
  end

  def self.attributes_for_data(data)
    attribs = {}
    et_img = EasyTag::Image.new(data)

    attribs[:type]        = et_img.type
    attribs[:description] = et_img.desc
    attribs[:checksum]    = Digest::SHA1.hexdigest(et_img.data).downcase
    attribs[:size]        = data.size

    attribs
  end

  def to_hash
    Hash.new.tap do |hash|
      [:type, :description, :checksum, :size].each { |k| hash[k] = send(k) }
    end
  end

  def to_json(obj)
    JSON.dump(image: to_hash)
  end
end
