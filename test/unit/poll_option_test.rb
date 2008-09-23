require File.dirname(__FILE__) + '/../test_helper'

class PollOptionTest < Test::Unit::TestCase
  fixtures :users, :polls, :poll_options

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
  
  def test_percent_chosen
    assert_equal 4, polls(:color_poll).user_responses.size
    assert_equal 3, poll_options(:color_poll_green_option).user_responses.size
    assert_equal 75, poll_options(:color_poll_green_option).percent_chosen
    
    assert_equal 1, poll_options(:color_poll_blue_option).user_responses.size
    assert_equal 25, poll_options(:color_poll_blue_option).percent_chosen
    
    assert_equal 0, poll_options(:color_poll_red_option).user_responses.size
    assert_equal 0, poll_options(:color_poll_red_option).percent_chosen
  end
end
