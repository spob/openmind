# == Schema Information
# Schema version: 20081021172636
#
# Table name: links
#
#    t.string   "name",        :limit => 30, :null => false
#    t.string   "url"
#    t.integer  "link_set_id"
#    t.datetime "created_at"
#    t.datetime "updated_at"
#    t.integer  "position"
#
require File.dirname(__FILE__) + '/../test_helper'

class LinkTest < ActiveSupport::TestCase
  fixtures :link_sets, :links
  
  should_belong_to :link_set
  
  should_require_unique_attributes :name, :scoped_to => :link_set_id
  should_ensure_length_in_range :name, (0..30)
  
  context "checking for heading" do
    should "indicate heading" do
      assert !links(:first_link_set_link).heading?
      assert !links(:second_link_set_link).heading?
      assert links(:heading_link_set_link).heading?
    end
  end
end
