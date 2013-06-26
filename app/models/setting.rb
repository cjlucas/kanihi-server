class Setting < ActiveRecord::Base
  attr_accessible :keyname, :value, :value_format
  validates_presence_of   :keyname, :value_format
  validates_uniqueness_of :keyname
end
