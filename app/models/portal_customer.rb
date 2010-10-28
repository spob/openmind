class PortalCustomer < ActiveRecord::Base  
  belongs_to :portal_org
  default_scope :order => 'serial_number'
end
