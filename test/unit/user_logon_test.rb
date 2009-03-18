# == Schema Information
# Schema version: 20081021172636
# 
# Table name: user_logons
# 
#  id           :integer(4)      not null, primary key
#  user_id      :integer(4)      not null
#  lock_version :integer(4)      default(0)
#  created_at   :datetime        not null
# 
require File.dirname(__FILE__) + '/../test_helper'

class UserLogonTest < ActiveSupport::TestCase 
  fixtures :user_logons, :users, :enterprises

  should_belong_to :user
  
  context "testing list" do
    should "return values from list" do
      assert !UserLogon.list(1, 10).empty?
    end
  end
end
