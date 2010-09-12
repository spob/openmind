class PortalCertifiedConsultant < ActiveRecord::Base
  belongs_to :portal_org
  
  named_scope :technical,
    :conditions => { :consultant_type => 'T'}
  named_scope :sales,
    :conditions => { :consultant_type => 'S'}
    
    default_scope :order => 'consultant_email'
end
