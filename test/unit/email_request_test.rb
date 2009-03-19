require File.dirname(__FILE__) + '/../test_helper'
    
class EmailRequestTest < ActiveSupport::TestCase 
  fixtures :users, :ideas, :email_requests

  should_belong_to :user
  should_require_attributes :to_email, :user, :subject
  
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
end