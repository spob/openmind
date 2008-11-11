require File.dirname(__FILE__) + '/../test_helper'

class UserRequestTest < Test::Unit::TestCase
  fixtures :user_requests

  should_require_attributes :email, 
    :last_name, 
    :enterprise_name, 
    :time_zone
  should_ensure_length_in_range :email, (3..100)
  should_allow_values_for :email,  "bob@openmindsw.com"
  should_not_allow_values_for :email, "bobopenmindsw.com", "bob@openmindswcom",
    :message => " does not appear to be a valid e-mail address"
  should_allow_values_for :first_name, 
    "1234567890123456789012345678901234567890"
  should_not_allow_values_for :first_name,
    "12345678901234567890123456789012345678901", 
    :message => "is too long (maximum is 40 characters)"
  should_allow_values_for :last_name, 
    "1234567890123456789012345678901234567890"
  should_not_allow_values_for :last_name,
    "12345678901234567890123456789012345678901", 
    :message => "is too long (maximum is 40 characters)"
  should_only_allow_numeric_values_for :initial_enterprise_allocation,
    :initial_user_allocation
  should_belong_to :enterprise, :enterprise_type
  should_have_and_belong_to_many :groups, :roles
  should_have_instance_methods :enterprise_id, :enterprise
  
  context "empty user request" do
    setup do
      @ur = UserRequest.new :email => "bob@openmind.org", 
        :last_name => "xxx",
        :enterprise_name => "yyy",
        :time_zone => "a"
      @ur.save
    end
    
    should "default status to pending" do
      assert_equal UserRequest.pending, @ur.status
    end
  end
  
  should "allow delete" do
    assert user_requests(:pending).can_delete?
  end
  
  should "return rows" do
    assert !UserRequest.list(1, 10, [UserRequest.pending], 50).empty?
    assert UserRequest.pending_requests?
  end
  
  context "testing constant values" do
    should "validate rejected" do
      assert "Rejected", UserRequest.rejected
    end
    
    should "validate approved" do
      assert "Approved", UserRequest.approved
    end
    
    should "validate pending" do
      assert "Pending", UserRequest.pending
    end    
    
    should "send notification" do
      assert_nothing_thrown {
        UserRequest.send_confirmation_email(user_requests(:pending).id)
      }
    end
  end
end
