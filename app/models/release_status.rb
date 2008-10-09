# == Schema Information
# Schema version: 20081008013631
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

class ReleaseStatus < LookupCode  
  has_many :releases,
    :dependent => :destroy
  
  def can_delete?
    releases.empty?
  end
end
