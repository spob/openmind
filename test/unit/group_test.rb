require File.dirname(__FILE__) + '/../test_helper'

class GroupTest < Test::Unit::TestCase
  fixtures :groups, :users
  
  should_require_unique_attributes :name
  should_require_attributes :description
  should_ensure_length_in_range :name, (0..50)
  should_ensure_length_in_range :description, (0..150)
  should_have_and_belong_to_many :users
  should_have_and_belong_to_many :forums
  should_have_and_belong_to_many :polls
  
  should "allow delete" do
    assert Group.new.can_delete?
  end
  
  should "allow edit" do
    assert Group.new.can_edit?(users(:quentin))
  end
  
  should "list all" do
    assert !Group.list_all.empty?
  end
  
  should "list" do
    assert !Group.list(1, 10).empty?
  end
end
