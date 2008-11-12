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

class ForumGroupTest < Test::Unit::TestCase
  fixtures :forums, :lookup_codes

  should_have_many :forums

  context "test can delete" do
    should "allow delete" do
      assert lookup_codes(:unassigned_forum_group).can_delete?
    end
    
    should "allow not delete" do
      assert !lookup_codes(:forum_group_abc).can_delete?
    end
  end
end