require File.dirname(__FILE__) + '/../test_helper'

class PollTest < Test::Unit::TestCase
  fixtures :polls, :poll_options, :users
  
  should_require_attributes :close_date
  should_require_unique_attributes :title 
  should_ensure_length_in_range :title, (0..200)
  should_have_and_belong_to_many :groups
  should_have_and_belong_to_many :enterprise_types
  should_have_many :comments, :dependent => :delete_all
  should_have_many :poll_options, :dependent => :destroy
  should_have_one :unselectable_poll_option

  def test_invalid_with_empty_attributes
    poll = Poll.new()
    assert !poll.valid?
    assert poll.errors.invalid?(:title)
    assert poll.errors.invalid?(:close_date)
  end
  
  def test_invalid_too_long
    title = "12345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890"
    assert_equal 200, title.length
    
    poll = Poll.new(:title => title, :close_date => Time.zone.now)
    assert poll.valid?
    
    poll = Poll.new(
      :title => title + "X", :close_date => Time.zone.now)
    assert !poll.valid?
    assert_equal "is too long (maximum is 200 characters)", 
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
    assert !noselect.selectable
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
  
  context "testing can take" do
    should "allow" do
      
    end
    
    should "not allow" do
      
    end
  end
end