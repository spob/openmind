require File.dirname(__FILE__) + '/../test_helper'

class PollTest < Test::Unit::TestCase
  fixtures :polls, :poll_options, :users

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
  
  def test_create
    poll = Poll.new(
      :title => "dummy",    
      :close_date => Date.today)
    assert poll.valid?
    
    poll.save
    poll = Poll.find(poll.id)
    assert 0, poll.poll_options.size
    assert 1, poll.poll_options_all.size
    noselect = poll.unselectable_poll_option
    assert_not_nil noselect
    assert false, noselect.selectable
  end
  
  def test_invalid_uniqueness
    poll = Poll.new(
      :title => "What is your favor color?")
    assert !poll.valid?
    assert_equal "has already been taken", 
      poll.errors.on(:title)
  end
  
  def test_open_polls
    assert 0, Poll.open_polls(users(:quentin)).size
  end
  
  def test_total_responses
    assert_equal 4, polls(:color_poll).total_responses
    assert_equal 0, polls(:no_options_poll).total_responses
    assert_equal 0, polls(:no_votes_poll).total_responses
  end
end