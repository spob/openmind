class SerialNumber < ActiveRecord::Base
  validates_uniqueness_of   :serial_number, :case_sensitive => false
  validates_length_of       :serial_number,    :is => 19
  
  has_many :serial_number_release_maps
  has_many :releases, :through => :serial_number_release_maps
  has_many :active_releases, :class_name => 'Release', :through => :serial_number_release_maps, 
  :source => :release, :conditions => 'serial_number_release_maps.disabled_at IS NULL'
  has_many :inactive_releases, :class_name => 'Release', :through => :serial_number_release_maps, 
  :source => :release, :conditions => 'serial_number_release_maps.disabled_at IS NOT NULL'
end
