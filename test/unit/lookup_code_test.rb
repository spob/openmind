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
require File.dirname(__FILE__) + '/../test_helper'

class LookupCodeTest < ActiveSupport::TestCase
  fixtures :lookup_codes
    
  should_require_unique_attributes :short_name, :description, :scoped_to  => "code_type"
  should_only_allow_numeric_values_for :sort_value
  should_ensure_length_in_range :short_name, (0..40)
  should_ensure_length_in_range :description, (0..50)
  
  should "return values" do
    assert !LookupCode.list(1, 10).empty?
  end
  
  should "allow deletion" do
    lc = LookupCode.new(:short_name => 'xxx', :description => "yyy", :sort_value => 99, :code_type => 'xxx')
    assert lc.can_delete?
  end
end
