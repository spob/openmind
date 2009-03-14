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

class CustomField < LookupCode
  
  def self.users_custom_boolean1
    field = 
      CustomField.find(:first, :conditions => "short_name = 'users_custom_boolean1'")
    field.description unless field.nil?
  end
end
