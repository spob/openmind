require File.dirname(__FILE__) + '/../test_helper'

class TopicCommentTest < Test::Unit::TestCase
  fixtures :comments, :ideas, :users, :topics
  
  should_belong_to :topic 
  should_require_attributes :topic_id
  
  context "testing can edit" do
    should "allow" do
      # test override = true
      assert comments(:topic_comment).can_edit?(users(:bob), true)
      # last author
      assert comments(:topic_comment3).can_edit?(users(:judy))
    end
    
    should "not allow" do
      assert !comments(:topic_comment).can_edit?(users(:bob), false)
      assert !comments(:topic_comment).can_edit?(users(:bob))
      assert !comments(:topic_comment3).can_edit?(users(:bob))
      assert !comments(:topic_comment2).can_edit?(users(:judy))
    end
  end
  
  def test_rss_headline
    assert_equal "Forum: bugs_forum, Topic: Topic one", comments(:topic_comment).rss_headline
  end
  
  should "format rss_body" do
    assert_equal "<i>Jim P wrote:</i><br/>topic comment", comments(:topic_comment).rss_body
  end
end