class PortalNfr < ActiveRecord::Base
  belongs_to :portal_org
  default_scope :order => 'expires_at DESC, serial_number'
end
