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

class AccountExec < LookupCode
  has_many :forecasts,
    :dependent => :destroy

  named_scope :by_short_name, :order => "short_name ASC"
  named_scope :by_sort_value, :order => "sort_value ASC"

  def can_delete?
    forecasts.empty?
  end

  def self.findall include_empty = false
    list = AccountExec.by_sort_value
    list.insert(0, AccountExec.new(:id => 0, :short_name => "")) if include_empty
    list
  end
end
