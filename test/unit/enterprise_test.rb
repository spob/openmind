require File.dirname(__FILE__) + '/../test_helper'

class EnterpriseTest < ActiveSupport::TestCase 
  fixtures :enterprises, :users

  should_require_attributes :name #, :active
  should_require_unique_attributes :name
  
  should_not_allow_values_for :name,  
    "123456789012345678901234567890123456789012345678901", 
    :message => "is too long (maximum is 50 characters)"
  should_allow_values_for :name, "abcd", "1234"

  should_have_many :users, :dependent => :destroy
  should_have_many :allocations, :dependent => :destroy
  should_have_many :votes, :through => :allocations
  should_belong_to :enterprise_type
  
  should_have_instance_methods :name, :active, :enterprise_type
  should_have_db_columns :enterprise_type_id
  should_have_index :name
  
  should "fetch enterprise" do
    e = Enterprise.find(:first)
    assert_not_nil e
  end
  
  should "retrieve active users" do
    e = enterprises(:active_enterprise)
    assert e.users.active.collect(&:id).include?(users(:quentin).id)
    assert !e.users.active.collect(&:id).include?(users(:inactive_user).id)
    assert !e.users.active.collect(&:id).include?(users(:imported_user).id)
  end
  
  should "enforce uniqueness" do
    enterprise2 = Enterprise.new(:name=>"Enterprise1", :active=> true)
    assert !enterprise2.save
    assert_equal ActiveRecord::Errors.default_error_messages[:taken], 
      enterprise2.errors.on(:name)
  end

  should "default to active" do
    e = Enterprise.new
    assert e.active
  end
  
  should "create a new enterprise" do
    e = Enterprise.create(
      :name => 'FooEnterpriseName1',
      :active => true)
    assert e.valid?
  end
  
  should "retrieve active enterprises" do
    assert_equal 5, Enterprise.active.size
  end
end