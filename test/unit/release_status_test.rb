require File.dirname(__FILE__) + '/../test_helper'

class ReleaseStatusTest < Test::Unit::TestCase
  fixtures :lookup_codes

  def test_invalid_with_empty_attributes
    release_status = ReleaseStatus.new
    assert !release_status.valid?
    assert release_status.errors.invalid?(:short_name)
    assert release_status.errors.invalid?(:description)
    release_status.sort_value = nil
    assert !release_status.errors.invalid?(:sort_value)
  end
  
  def test_valid_with_attributes
    release_status = ReleaseStatus.new(:short_name => "test", 
      :description => "description", :sort_value => 22)
    assert release_status.valid?
  end
  
  def test_sort_value_default
    release_status = ReleaseStatus.new
    assert 100, release_status.sort_value
  end
  
  def test_save
    release_status = ReleaseStatus.new(:short_name => 
        "123", :description => "description")
    assert release_status.save
  end
  
  def test_fetch
    release_status = ReleaseStatus.find(:first)
    assert_not_nil release_status
  end
  
  def test_uniqueness
    release_status = ReleaseStatus.new(:short_name => 
        "fooShortName1", :description => "description")
    assert !release_status.save
    assert_equal ActiveRecord::Errors.default_error_messages[:taken], 
      release_status.errors.on(:short_name)
  end
  
  def test_invalid_too_long
    release_status = ReleaseStatus.new(
      :short_name => "12345678901234567890123456789012345678901", 
      :description => "description")
    assert !release_status.valid?
    assert_equal "is too long (maximum is 40 characters)", 
      release_status.errors.on(:short_name)
  end
end
