require File.dirname(__FILE__) + '/../test_helper'

class TopicCommentTest < Test::Unit::TestCase
  fixtures :comments, :ideas, :users, :topics
  
  def test_rss_headline
    assert_equal "Forum: bugs_forum, Topic: Topic one", comments(:topic_comment).rss_headline
  end
end