require File.dirname(__FILE__) + '/../test_helper'

class EnterpriseTypeTest < ActiveSupport::TestCase 
  fixtures :enterprises, :lookup_codes

  should_require_attributes :description
  should_require_unique_attributes :short_name
  should_have_db_column :sort_value, :default => 100
  should_allow_values_for :short_name,  
    "1234567890123456789012345678901234567890"
  should_not_allow_values_for :short_name,  
    "12345678901234567890123456789012345678901", 
    :message => "is too long (maximum is 40 characters)"
  
  should "successfully create" do
    et = EnterpriseType.new(:short_name => "test", 
      :description => "description", :sort_value => 22)
    assert et.valid?
  end
  
  should "successfully save" do
    et = EnterpriseType.new(:short_name => 
        "123", :description => "description")
    assert et.save
  end
  
  should "successfully fetch" do
    et = EnterpriseType.find(:first)
    assert_not_nil et
  end
  
  should "list all" do
    assert !EnterpriseType.by_sort_value.empty?
    assert !EnterpriseType.by_short_name.empty?
  end
  
  should "all delete" do
    et = lookup_codes(:enterprise_type_abc)
    assert !et.enterprises.empty?
    assert !et.can_delete?
  end
  
  should "find all" do
    assert_equal EnterpriseType.findall.size + 1, EnterpriseType.findall(true).size
  end
end
