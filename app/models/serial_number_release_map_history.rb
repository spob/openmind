class SerialNumberReleaseMapHistory < ActiveRecord::Base
  belongs_to :serial_number_release_map
  validates_presence_of :serial_number_release_map
  validates_presence_of :action
end
