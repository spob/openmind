require File.dirname(__FILE__) + '/../test_helper'

class PollOptionTest < Test::Unit::TestCase
  fixtures :poll_options

  def test_invalid_with_empty_attributes
    poll_option = PollOption.new
    assert !poll_option.valid?
    assert poll_option.errors.invalid?(:description)
  end
  
  def test_invalid_too_long
    poll_option = PollOption.new(
      :description => "0123456789001234567890012345678900123456789001234567890123456789012345678901234567890123456789012345678901234567890123456789x")
    assert !poll_option.valid?
    assert_equal "is too long (maximum is 120 characters)", 
      poll_option.errors.on(:description)
  end
  
  def test_valid_with_attributes
    poll_option = PollOption.new(
      :description => "dummy")
    assert poll_option.valid?
  end
end
