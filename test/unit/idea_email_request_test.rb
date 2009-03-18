#    t.integer  "idea_id"
#    t.datetime "created_at"
#    t.datetime "updated_at"
#    t.datetime "sent_at"
#    t.text     "message"
#    t.string   "subject",                   :null => false
#    t.string   "to_email",                  :null => false
#    t.boolean  "cc_self"
#    t.integer  "user_id",                   :null => false
#    t.string   "type",       :limit => 100, :null => false

require File.dirname(__FILE__) + '/../test_helper'

class IdeaEmailRequestTest < ActiveSupport::TestCase 
  fixtures :ideas, :users, :email_requests, :products

  should_require_attributes :idea
  should_belong_to :idea
  
  should "check my sanity" do
    assert !EmailRequest.find(:all).empty?
  end
  
  should "send request" do
    assert_nothing_thrown {
      IdeaEmailRequest.email_idea(email_requests(:pending_email_request).id)
    }
    unsent_request = IdeaEmailRequest.find(email_requests(:pending_email_request).id)
    assert_not_nil unsent_request.sent_at
  end
end