require File.dirname(__FILE__) + '/../test_helper'

class AllocationTest < Test::Unit::TestCase
  fixtures :enterprises, :allocations, :votes, :users, :ideas

  should_have_many :votes,  :dependent => :destroy
  should_only_allow_numeric_values_for :quantity
  should_require_attributes :expiration_date
  
  def test_polymorphism
    user_allocation_count = 0;
    enterprise_allocation_count = 0;
    for allocation in Allocation.find(:all)
      user_allocation_count += 1 if allocation.class == UserAllocation
      enterprise_allocation_count += 1 if allocation.class == EnterpriseAllocation
    end
    assert user_allocation_count > 0
    assert enterprise_allocation_count > 0
  end
  
  def test_greater_than_votes
    
    # make sure at least 2 votes exist
    user = users(:allocation_calculation_test)
    idea = ideas(:available_votes_calc_test1)
    allocation = allocations(:user_allocation)
    allocation.votes.create(:idea_id => idea.id,
      :user_id => user.id)
    allocation.votes.create(:idea_id => idea.id,
      :user_id => user.id)
    allocation.quantity = 
      allocation.votes.size - 1
    assert !allocation.valid?
    assert_equal "must be greater than the votes used, which is #{allocation.votes.size}", 
      allocation.errors.on(:quantity)
  end
  
  def test_available_quantity
    assert_equal 9, allocations(:user_allocation).available_quantity
    
    allocations(:user_allocation).votes.delete_all
    assert_equal 10, allocations(:user_allocation).available_quantity
  end
  
  #  def test_allocated_to
  #    assert_equal "Bob A",
  #      allocations(:user_allocation).allocated_to.display_name
  #    assert_equal "Enterprise1", allocations(:enterprise_allocation).allocated_to.name
  #  end
  
  def test_vote_count    
    assert_equal 1, allocations(:user_allocation).votes.size
    allocations(:user_allocation).votes.delete_all
    assert_equal 0, allocations(:user_allocation).votes.size
  end
  
  def test_can_delete
    assert !allocations(:user_allocation).can_delete?
    allocations(:user_allocation).votes.delete_all
    assert allocations(:user_allocation).can_delete?
  end
  
  def test_valid
    allocation = UserAllocation.create(:quantity => 1, 
      :user_id => users(:quentin).id,
      :comments => "xxxx" )
    Allocation.find(allocation.id)
  end
  
  def test_invalid_too_long
    allocation = create_allocation repeat('x', 255)
    assert allocation.valid?
    allocation = create_allocation repeat('x', 256)
    assert !allocation.valid?
    assert_equal "is too long (maximum is 255 characters)", 
      allocation.errors.on(:comments)
  end
  
  def test_numericality
    allocation = UserAllocation.new(:quantity => "a", 
      :user_id => users(:quentin).id,
      :comments => "xxx" )
    assert !allocation.valid?
    assert_equal ["is not a number", "should be at least 1 or greater"], 
      allocation.errors.on(:quantity)
  end
  
  should "retrieve allocations for user" do
    assert !Allocation.list_all_for_user(users(:allroles), 1, 10, false).empty?
    assert !Allocation.list_all_for_user(users(:allroles), 1, 10, true).empty?
  end
  
  should "retrieve allocations" do
    assert !Allocation.list(users(:allroles), nil, true, 1, 10, false).empty?
    assert !Allocation.list(users(:allroles), nil, false, 1, 10, false).empty?
    assert !Allocation.list(nil, users(:allocation_calculation_test), true, 1, 10, false).empty?
    assert !Allocation.list(nil, users(:allocation_calculation_test), false, 1, 10, false).empty?
    assert !Allocation.list(users(:allroles), users(:allocation_calculation_test), true, 1, 10, false).empty?
    assert !Allocation.list(users(:allroles), users(:allocation_calculation_test), false, 1, 10, false).empty?
    
    assert !Allocation.list(users(:allroles), nil, true, 1, 10, true).empty?
    assert !Allocation.list(users(:allroles), nil, false, 1, 10, true).empty?
    assert !Allocation.list(nil, users(:allocation_calculation_test), true, 1, 10, true).empty?
    assert !Allocation.list(nil, users(:allocation_calculation_test), false, 1, 10, true).empty?
    assert !Allocation.list(users(:allroles), users(:allocation_calculation_test), true, 1, 10, true).empty?
    assert !Allocation.list(users(:allroles), users(:allocation_calculation_test), false, 1, 10, true).empty?
  end
  
  def test_user_expiration
    #        puts "============start users"
    #        for a in UserAllocation.find_all_by_user_id(users(:alloc_expiring_user))
    #          puts "#{a.id} #{a.expiration_date} #{a.expiration_date.jd - Date.today.jd}"
    #        end
    #        puts "============start enterprise"
    #        for a in EnterpriseAllocation.find_all_by_enterprise_id(users(:alloc_expiring_user).enterprise)
    #          puts "#{a.id} #{a.expiration_date} #{a.expiration_date.jd - Date.today.jd}"
    #        end
    assert_equal 14, Allocation.expiring_allocation_days(users(:alloc_expiring_user))
    assert_equal 119, Allocation.expiring_allocation_days(users(:force_change_pw))
  end
  
  context "testing string conversion" do
    should "convert to strings" do
      assert_equal "User Allocation, user: all@example.com, quantity: 10", allocations(:user_allocation).to_s
      assert_equal "Enterprise Allocation, enterprise: Enterprise1, quantity: 100", allocations(:enterprise_allocation).to_s
    end
  end
  
  private
  
  def create_allocation(str)
    UserAllocation.new(:quantity => 1, 
      :user_id => users(:quentin).id,
      :comments => str )
  end
  
  def repeat(str, len)
    buf = ""
    (1..len).each do |i|
      buf += str
    end
    buf
  end
end
