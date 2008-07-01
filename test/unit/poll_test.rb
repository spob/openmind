require File.dirname(__FILE__) + '/../test_helper'

class PollTest < Test::Unit::TestCase
  fixtures :polls

  def test_invalid_with_empty_attributes
    poll = Poll.new()
    assert !poll.valid?
    assert poll.errors.invalid?(:title)
    assert poll.errors.invalid?(:close_date)
  end
  
  def test_invalid_too_long
    poll = Poll.new(
      :title => "0123456789001234567890012345678900123456789001234567890123456789012345678901234567890123456789012345678901234567890123456789x")
    assert !poll.valid?
    assert_equal "is too long (maximum is 120 characters)", 
      poll.errors.on(:title)
  end
  
  def test_valid_with_attributes
    poll = Poll.new(
      :title => "dummy",    
      :close_date => Date.today)
    assert poll.valid?
  end
  
  def test_invalid_uniqueness
    poll = Poll.new(
      :title => "What is your favor color?")
    assert !poll.valid?
    assert_equal "has already been taken", 
      poll.errors.on(:title)
  end
  
  def test_total_responses
    assert_equal 4, polls(:color_poll).total_responses
    assert_equal 0, polls(:no_options_poll).total_responses
    assert_equal 0, polls(:no_votes_poll).total_responses
  end
end
