class PortalUserOrgMap < ActiveRecord::Base
  belongs_to :portal_org
  named_scope :active, :conditions => ["user_disabled_at IS NULL or user_disabled_at > ?", Time.now]
  named_scope :portal_end_customer_orgs, :conditions => { :org_type => 'E'}
  named_scope :portal_reseller_orgs, :conditions => { :org_type => 'R'}
  named_scope :by_org_id, lambda{|org_id|{:conditions => { :external_org_id => org_id }}}
  named_scope :by_email, lambda{|email|{:conditions => { :email => email }, :order => 'org_name'}}
  
  def self.match_org_ids
    sql = 
<<-eos
      update portal_user_org_maps as uo
set portal_org_id =
 (select id
  from portal_orgs as o
  where o.external_org_id = uo.external_org_id)
where uo.portal_org_id is null
  and exists
  (select null
  from portal_orgs as o
  where o.external_org_id = uo.external_org_id)
eos
    
    ActiveRecord::Base.connection.execute(sql) 
  end
  
  def self.disable_users
    
    sql = 
<<-eos
      select users.*
from users
where users.active = 1
and exists
( select null
  from portal_user_org_maps as puo
  where puo.email = users.email
    and puo.user_disabled_at < now())
and not exists
(select null
  from portal_user_org_maps as puo
  where puo.email = users.email
    and puo.user_disabled_at >= now() or puo.user_disabled_at is null);
eos
    
    User.find_by_sql(sql).each do |u|
      u.update_attributes!(:active => false)
    end
  end
end
