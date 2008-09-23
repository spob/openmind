require File.dirname(__FILE__) + '/../test_helper'

class UserTest < Test::Unit::TestCase
  # Be sure to include AuthenticatedTestHelper in test/test_helper.rb instead.
  # Then, you can remove it from this and the functional test.
  include AuthenticatedTestHelper
  fixtures :users, :enterprises, :allocations, :votes, :roles, :topics

  def test_full_name
    user = User.new(:last_name => "xxx")
    assert_equal "xxx", user.full_name
    
    user.first_name = "bbb"
    assert_equal "bbb xxx", user.full_name
  end
  
  def test_user_logons_90_days
    assert_nothing_raised {
      users(:quentin).user_logons_90_days
    }
  end
  
  def test_imported_users
    found = false
    for user in User.imported_users
      found = true
      assert_nil user.activated_at
      assert_nil user.activation_code
    end
    assert found
  end
  
  def test_short_name
    user = User.new(:first_name => "Joe", :last_name => "Smith", :email => "yyy", :hide_contact_info => true)
    assert_equal "Joe S", user.display_name
    user = User.new(:last_name => "Smith", :email => "yyy", :hide_contact_info => true)
    assert_equal "Smith", user.display_name
  end
  
  def test_display_name
    user = User.new(:last_name => "xxx", :email => "yyy", :hide_contact_info => false)
    assert_equal "xxx (yyy)", user.display_name
    user = User.new(:last_name => "xxx", :email => "yyy", :hide_contact_info => true)
    assert_equal "xxx (yyy)", user.display_name(true)
    user = User.new(:last_name => "xxx", :email => "yyy", :hide_contact_info => true)
    assert_equal "xxx", user.display_name
  end
  
  def test_create_and_destroy
    user = User.new({ :email => 'changeme@openmind.org', 
        :password => 'changeme', :password_confirmation => 'changeme',
        :last_name => "xxx",
        :salt => 'sodiumchrolide',
        :enterprise_id => enterprises(:active_enterprise).id })
    user.save!
    user.destroy
  end
  
  def test_should_create_user
    assert_difference 'User.count', 1 do
      user = create_user
      assert_equal 10, user.row_limit
      assert !user.new_record?, "#{user.errors.full_messages.to_sentence}"
    end
  end

  def test_should_not_require_login
    u = create_user( :email => 'dummy@openmind.com',
      :enterprise_id => enterprises(:active_enterprise).id)
    assert u.valid?
  end

  def test_should_require_password
    assert_no_difference 'User.count' do
      u = create_user(:password => nil)
      assert u.errors.on(:password)
    end
  end

  def test_should_require_password_confirmation
    assert_no_difference 'User.count' do
      u = create_user(:password_confirmation => nil)
      assert u.errors.on(:password_confirmation)
    end
  end

  def test_should_require_email
    assert_no_difference 'User.count' do
      u = create_user(:email => nil)
      assert u.errors.on(:email)
    end
  end

  def test_should_require_valid_email
    assert_no_difference 'User.count' do
      u = create_user(:email => "xxx")
      assert u.errors.on(:email)
    end
  end
  
  def test_should_require_row_count_greater_than_one
    assert_no_difference 'User.count' do
      u = create_user(:row_limit => 0)
      assert u.errors.on(:row_limit)
    end
  end

  def test_should_reset_password
    users(:quentin).update_attributes(:password => 'new password', :password_confirmation => 'new password')
    assert_equal users(:quentin), User.authenticate('quentin@example.com', 'new password')
  end

  def test_should_not_rehash_password
    users(:quentin).update_attributes(:login => 'quentin@example.com')
    assert_equal users(:quentin), User.authenticate('quentin@example.com', 'secret')
  end

  def test_should_authenticate_user
    assert_equal users(:quentin), User.authenticate('quentin@example.com', 'secret')
  end

  def test_should_not_authenticate_user_inactive_enterprise
    assert_not_equal users(:active_user_inactive_enterprise), User.authenticate('inactiveenterprise@example.com', 'secret')
  end

  def test_should_not_authenticate_inactive_user
    assert_not_equal users(:inactive_user), User.authenticate('inactive@example.com', 'secret')
  end

  def test_should_set_remember_token
    users(:quentin).remember_me
    assert_not_nil users(:quentin).remember_token
    assert_not_nil users(:quentin).remember_token_expires_at
  end

  def test_should_unset_remember_token
    users(:quentin).remember_me
    assert_not_nil users(:quentin).remember_token
    users(:quentin).forget_me
    assert_nil users(:quentin).remember_token
  end
  
  def test_available_votes_calc
    alloc_user = users(:allocation_calculation_test)
    assert_equal 30, alloc_user.available_user_votes
    assert_equal 14, alloc_user.available_enterprise_votes
    assert_equal 44, alloc_user.available_votes
  end
  
  def test_votes_has_many
    assert_equal 2, users(:allocation_calculation_test).votes.size
    assert_equal 3, users(:allocation_calculation_test).all_votes.size
  end
  
  def test_logons
    assert_nothing_raised {
      users(:quentin).last_logon
      users(:quentin).user_logons
    } 
  end
  
  def test_active_users
    assert_nothing_raised {
      User.active_users
    } 
    assert !User.active_users.empty?
    assert_not_nil User.active_users.index(users(:allroles))
    assert_nil User.active_users.index(users(:inactive_user))
  end
  
  def test_active_voters
    assert_nothing_raised {
      User.active_voters
    } 
    assert User.active_users.size > User.active_voters.size
    assert_not_nil User.active_voters.index(users(:allroles))
    assert_nil User.active_voters.index(users(:user_no_roles))
  end
  
  def test_watch_topic
    user = users(:quentin)
    assert user.watched_topics.empty?
    
    topic = topics(:bug_topic1)
    user.watch_topic(topic)
    user.save
    user = User.find(user.id)
    assert !user.watched_topics.empty?
    assert 1, user.watched_topics.count
    topic2 = user.watched_topics.first
    assert topic, topic2
  end

  protected
  def create_user(options = {})
    User.create({ :email => 'quire@example.com', 
        :password => 'quire', 
        :password_confirmation => 'quire',
        :last_name => 'Blah',
        :enterprise_id => enterprises(:active_enterprise).id }.merge(options))
  end
end
