require File.dirname(__FILE__) + '/../test_helper'

class EnterpriseTypeTest < Test::Unit::TestCase
  fixtures :enterprises, :lookup_codes

  def test_invalid_with_empty_attributes
    enterprise_type = EnterpriseType.new
    assert !enterprise_type.valid?
    assert enterprise_type.errors.invalid?(:short_name)
    assert enterprise_type.errors.invalid?(:description)
  end
  
  def test_valid_with_attributes
    et = EnterpriseType.new(:short_name => "test", 
      :description => "description", :sort_value => 22)
    assert et.valid?
  end
  
  def test_sort_value_default
    et = EnterpriseType.new
    assert 100, et.sort_value
  end
  
  def test_save
    et = EnterpriseType.new(:short_name => 
        "123", :description => "description")
    assert et.save
  end
  
  def test_fetch
    et = EnterpriseType.find(:first)
    assert_not_nil et
  end
  
  def test_uniqueness
    test_save
    enterprise_type = EnterpriseType.new(:short_name => 
        "123", :description => "description")
    assert !enterprise_type.save
    assert_equal ActiveRecord::Errors.default_error_messages[:taken], 
      enterprise_type.errors.on(:short_name)
  end
  
  def test_invalid_too_long
    et = EnterpriseType.new(
      :short_name => "12345678901234567890123456789012345678901", 
      :description => "description")
    assert !et.valid?
    assert_equal "is too long (maximum is 40 characters)", 
      et.errors.on(:short_name)
  end
  
  def test_list_all
    assert !EnterpriseType.list_all.empty?
  end
  
  def test_can_delete
    et = lookup_codes(:enterprise_type_abc)
    assert !et.enterprises.empty?
    assert !et.can_delete?
  end
  
  def test_findall
    assert_equal EnterpriseType.findall.size + 1, EnterpriseType.findall(true).size
  end
end
