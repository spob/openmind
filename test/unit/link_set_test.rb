# == Schema Information
# Schema version: 20081021172636
# 
# Table name: link_sets
# 
#  id               :integer(4)      not null, primary key
#  name             :string(30)      not null
#  created_at       :datetime
#  updated_at       :datetime
#  label            :string(30)      not null
#  default_link_set :boolean(1)      not null
# 
require File.dirname(__FILE__) + '/../test_helper'

class LinkSetTest < ActiveSupport::TestCase
  fixtures :link_sets, :forums, :links
  
  should_have_many :links, :dependent => :destroy
  should_have_many :forums
  
  should_require_attributes :label, :name
  should_require_unique_attributes :name
  should_ensure_length_in_range :name, (0..30)
  should_ensure_length_in_range :label, (0..30)
  
  should "retrieve links" do
    assert_equal 3, link_sets(:first_link_set).links.size
  end
  
  context "testing list methods" do
    should "list link sets" do
      assert !LinkSet.list(1, 10).empty?
    end
    
    should "retrieve all link sets" do
      assert LinkSet.list_all(false).size < LinkSet.list_all(true).size
    end
  end
  
  context "checking default link logic" do
    setup do
      @default = LinkSet.get_default_link_set
      assert_not_nil @default
      assert_equal @default, link_sets(:default_link_set)
      assert @default.default_link_set
    end
    
    should "unset existing default link set" do
      @new_ls = LinkSet.create(:name => 'hello', :label => '123', :default_link_set => true)
      assert_not_nil @new_ls
      @default = LinkSet.find(@default)
      assert !@default.default_link_set
    end
    
    should "not unset existing default link set" do
      @new_ls = LinkSet.create(:name => 'hello', :label => '123', :default_link_set => false)
      assert_not_nil @new_ls
      @default = LinkSet.find(@default)
      assert @default.default_link_set
    end
    
    context "testing edit and delete" do
      should "enable edit" do
        assert link_sets(:default_link_set).can_edit?
        assert link_sets(:empty_link_set).can_edit?
        assert link_sets(:forum_link_set).can_edit?
      end
      
      should "enable delete" do
        assert link_sets(:empty_link_set).can_delete?
      end
      
      should "prevent delete" do
        assert !link_sets(:default_link_set).can_delete?
        assert !link_sets(:forum_link_set).can_delete?
      end
    end
  end
end
