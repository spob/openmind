require File.dirname(__FILE__) + '/../test_helper'

class RoleTest < Test::Unit::TestCase
  fixtures :roles

  should_require_unique_attributes :title, :description
  should_ensure_length_in_range :title, (0..50)
  should_ensure_length_in_range :description, (0..50)
  should_have_and_belong_to_many :users 
  
  context "testing list" do
    should "retrieve values" do
      assert !Role.list.empty?
    end
  end
  
  should "not allow delete" do
    for role in Role.list
      assert !role.can_delete?
    end
  end
  
  should "find default role" do
    assert !Role.find_default_roles.empty?
  end
  
  def test_invalid_with_empty_attributes
    role = Role.new
    assert !role.valid?
    assert role.errors.invalid?(:title)
    assert role.errors.invalid?(:description)
  end
  
  def test_invalid_too_long
    role = Role.new(:title => "01234567890123456789012345678901234567890123456789x", 
      :description => "01234567890123456789012345678901234567890123456789x")
    assert !role.valid?
    assert_equal "is too long (maximum is 50 characters)", 
      role.errors.on(:title)
    assert_equal "is too long (maximum is 50 characters)", 
      role.errors.on(:description)
  end
  
  def test_valid_with_attributes
    role = Role.new(:title => "test", 
      :description => "test")
    assert role.valid?
  end
  
  def test_uniqueness
    role = Role.new(:title => roles(:dummy_role).title, :description => "xxx")
    assert !role.save
    assert_equal ActiveRecord::Errors.default_error_messages[:taken], 
      role.errors.on(:title)
    
    
    role = Role.new(:description => roles(:dummy_role).description, :title => "xxx")
    assert !role.save
    assert_equal ActiveRecord::Errors.default_error_messages[:taken], 
      role.errors.on(:description)
  end
end
