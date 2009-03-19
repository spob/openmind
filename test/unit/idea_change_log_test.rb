#    t.integer  "idea_id",      :null => false
#    t.integer  "user_id",      :null => false
#    t.text     "message",      :null => false
#    t.datetime "processed_at"
#    t.datetime "created_at"
#    t.datetime "updated_at"

require File.dirname(__FILE__) + '/../test_helper'

class IdeaChangeLogTest < ActiveSupport::TestCase 
  fixtures :ideas, :users, :idea_change_logs

  should_require_attributes :user, :message
  should_allow_values_for :message, "abcd", "1234"

  should_belong_to :user
  should_belong_to :idea
  
  should_have_instance_methods :user, :idea, :message
  
  context "when creating an idea" do
    setup do
      @idea = ideas(:first_idea)  
      assert_not_nil @idea
    end
    
    should "successfully create change log" do
      log = IdeaChangeLog.new(
        :message => "Idea created", 
        :user => users(:allroles),
        :processed_at => Time.zone.now)
      @idea.change_logs << log
      
      assert @idea.save
    end
  end
end