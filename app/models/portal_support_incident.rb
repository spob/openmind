class PortalSupportIncident < ActiveRecord::Base
  belongs_to :portal_org
    
    default_scope :order => 'case_number DESC'
end
