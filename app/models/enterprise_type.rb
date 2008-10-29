# == Schema Information
# Schema version: 20081021172636
#
# Table name: lookup_codes
#
#  id           :integer(4)      not null, primary key
#  code_type    :string(30)      not null
#  short_name   :string(40)      not null
#  description  :string(50)      not null
#  sort_value   :integer(4)      default(100), not null
#  created_at   :datetime        not null
#  lock_version :integer(4)      default(0)
#  updated_at   :datetime        not null
#

class EnterpriseType < LookupCode  
  has_many :enterprises,
    :dependent => :destroy
  has_and_belongs_to_many :polls
  has_many :users, :through => :enterprises
  
  def self.list_all
    EnterpriseType.find(:all, :order => 'short_name ASC')
  end
  
  def can_delete?
    enterprises.empty?
  end
  
  def self.findall include_empty = false
    list = EnterpriseType.find(:all, :order => "sort_value")
    list.insert(0, EnterpriseType.new(:id => 0, :short_name => "")) if include_empty
    list
  end
end