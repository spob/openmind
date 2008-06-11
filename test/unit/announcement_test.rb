require File.dirname(__FILE__) + '/../test_helper'

class AnnouncementTest < Test::Unit::TestCase
  fixtures :announcements, :users

  
  def test_invalid_with_empty_attributes
    announcement = Announcement.new()
    assert !announcement.valid?
    assert announcement.errors.invalid?(:headline)
    assert announcement.errors.invalid?(:description)
  end
  
  def test_list
    assert !Announcement.list(1, 10).empty?
    assert_equal 2, Announcement.list(1, 10, 2).size
  end
  
  def test_invalid_too_long
    announcement = Announcement.new(
      :headline => "01234567890123456789012345678901234567890123456789012345678901234567890123456789x")
    assert !announcement.valid?
    assert_equal "is too long (maximum is 80 characters)", 
      announcement.errors.on(:headline)
  end
  
  def test_valid_with_attributes
    announcement = Announcement.new(
      :headline => "dummy",    
      :description => "abc")
    assert announcement.valid?
  end
  
  @@day = 60*60*24
  
  def test_unread_announcements
    user = users(:quentin)
    assert user.last_message_read.nil?
    assert user.unread_announcements?
    
    user.last_message_read = Time.now - 10 * @@day
    assert user.unread_announcements?
    
    user.last_message_read = Time.now
    assert !user.unread_announcements?
    
    Announcement.delete_all 
    user.last_message_read = Time.now - 10 * @@day
    assert !user.unread_announcements?
  end
  
  def test_unread?
    announcement = announcements(:normal1)
    user = users(:quentin)
    user.last_message_read = nil
    
    assert announcement.unread?(user)
    
    user.last_message_read = Time.now - 10 * @@day
    assert announcement.unread?(user)
    
    user.last_message_read = Time.now
    assert !announcement.unread?(user)
  end
end
