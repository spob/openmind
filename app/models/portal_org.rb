class PortalOrg < ActiveRecord::Base
  has_many :portal_customers, :conditions => ["portal_customers.serial_number not like ?", 'NFR!%'], :order => 'maintenance_expires_at DESC'
  has_many :portal_certified_consultants, :order => 'consultant_email'
  has_many :portal_nfrs, :order => 'expires_at DESC, serial_number'
  has_many :portal_support_incidents, :order => 'case_number DESC'
  has_many :portal_user_org_maps
  has_many :portal_entitlements
  default_scope :order => 'org_name'
end
