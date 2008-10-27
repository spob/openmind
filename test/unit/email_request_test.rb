require File.dirname(__FILE__) + '/../test_helper'
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
    
class EmailRequestTest < Test::Unit::TestCase
  fixtures :users, :ideas, :email_requests

  def test_should_be_value
    e = IdeaEmailRequest.new(:idea => ideas(:first_idea), 
      :subject => 'xxx', 
      :user => users(:quentin),
      :to_email => 'joe@scribesoftwc.com')
    
    assert e.valid? 
  end

  def test_should_require_to_email
    e = IdeaEmailRequest.new(:idea => ideas(:first_idea), 
      :subject => 'xxx',
      :to_email => 'joe@scribesoftwc.com')
    
    assert !e.valid?    
    assert e.errors.invalid?(:user)
    assert_equal "can't be blank", 
      e.errors.on(:user)
  end

  def test_should_require_subject
    e = IdeaEmailRequest.new(:idea => ideas(:first_idea), 
      :user => users(:quentin),
      :to_email => 'joe@scribesoftwc.com')
    
    assert !e.valid?    
    assert e.errors.invalid?(:subject)
    assert_equal "can't be blank", 
      e.errors.on(:subject)
  end

  def test_should_require_idea
    e = IdeaEmailRequest.new(
      :user => users(:quentin),
      :subject => 'xxx',
      :to_email => 'joe@scribesoftwc.com')
    
    assert !e.valid?    
    assert e.errors.invalid?(:idea)
    assert_equal "can't be blank", 
      e.errors.on(:idea)
  end
#    e = email_requests(:simple_idea_email_request)

#  def test_fetch
#    e = Enterprise.find(:first)
#    assert_not_nil e
#  end
#  
#  def test_active_users
#    e = enterprises(:active_enterprise)
#    assert e.active_users.collect(&:id).include?(users(:quentin).id)
#    assert !e.active_users.collect(&:id).include?(users(:inactive_user).id)
#    assert !e.active_users.collect(&:id).include?(users(:imported_user).id)
#  end
#
#  def test_invalid_too_long
#    e = Enterprise.new(:name=> "123456789012345678901234567890123456789012345678901",
#      :active => true)
#    assert !e.valid?
#    assert_equal "is too long (maximum is 50 characters)", 
#      e.errors.on(:name)
#  end
#  
#  def test_uniqueness
#    enterprise2 = Enterprise.new(:name=>"Enterprise1", :active=> true)
#    assert !enterprise2.save
#    assert_equal ActiveRecord::Errors.default_error_messages[:taken], 
#      enterprise2.errors.on(:name)
#  end
#
#  def test_active_default
#    e = Enterprise.new
#    assert e.active
#  end
#  
#  def test_should_create_enterprise
#    e = Enterprise.create(
#      :name => 'FooEnterpriseName1',
#      :active => true)
#    assert e.valid?
#  end
#  
#  def test_active_enterprises
#   assert_equal 3, Enterprise.active_enterprises.size
#  end
end