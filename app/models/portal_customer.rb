class PortalCustomer < ActiveRecord::Base  
  belongs_to :portal_org
  default_scope :order => 'serial_number'

  def expires_at
    maintenance_expires_at
  end

  def registered_to
    portal_org.org_name
  end
end
