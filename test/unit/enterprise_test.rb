require File.dirname(__FILE__) + '/../test_helper'

class EnterpriseTest < Test::Unit::TestCase
  fixtures :enterprises, :users

  def test_should_require_name
    e = Enterprise.create(:name => nil)
    assert e.errors.on(:name)
  end

  def test_fetch
    e = Enterprise.find(:first)
    assert_not_nil e
  end
  
  def test_active_users
    e = enterprises(:active_enterprise)
    assert e.active_users.collect(&:id).include?(users(:quentin).id)
    assert !e.active_users.collect(&:id).include?(users(:inactive_user).id)
    assert !e.active_users.collect(&:id).include?(users(:imported_user).id)
  end

  def test_invalid_too_long
    e = Enterprise.new(:name=> "123456789012345678901234567890123456789012345678901",
      :active => true)
    assert !e.valid?
    assert_equal "is too long (maximum is 50 characters)", 
      e.errors.on(:name)
  end
  
  def test_uniqueness
    enterprise2 = Enterprise.new(:name=>"Enterprise1", :active=> true)
    assert !enterprise2.save
    assert_equal ActiveRecord::Errors.default_error_messages[:taken], 
      enterprise2.errors.on(:name)
  end

  def test_active_default
    e = Enterprise.new
    assert e.active
  end
  
  def test_should_create_enterprise
    e = Enterprise.create(
      :name => 'FooEnterpriseName1',
      :active => true)
    assert e.valid?
  end
  
  def test_active_enterprises
   assert_equal 4, Enterprise.active_enterprises.size
  end
end