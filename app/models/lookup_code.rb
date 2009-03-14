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

class LookupCode < ActiveRecord::Base
  
  validates_presence_of :short_name, :description
  validates_numericality_of :sort_value, :only_integer => true, :allow_nil => false
  validates_length_of :short_name, :maximum => 40
  validates_length_of :description, :maximum => 50
  validates_uniqueness_of :short_name, :scope => "code_type", :case_sensitive => false
  validates_uniqueness_of :description, :scope => "code_type", :case_sensitive => false
  
  def self.inheritance_column
    'code_type'
  end
  
  def self.list(page, per_page)
    paginate :page => page, :order => 'code_type, sort_value', 
      :per_page => per_page
  end
  
  def can_delete?
    return true
  end
end
