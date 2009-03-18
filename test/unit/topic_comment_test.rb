require File.dirname(__FILE__) + '/../test_helper'

class TopicCommentTest < ActiveSupport::TestCase 
  fixtures :comments, :ideas, :users, :topics
  
  should_belong_to :topic
  should_have_db_column :endorser_id, :default => nil, :null => true
  should_have_instance_methods :endorser
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

  context "testing can endorse logic" do
    should "allow endorse" do
      comment = comments(:topic_comment)
      assert comment.can_endorse?(users(:allroles))

      comment.endorser = users(:allroles)
      assert comment.can_unendorse?(users(:allroles))
    end

    should "not allow endorse" do
      comment = comments(:topic_comment)
      # not mediator
      assert !comment.can_endorse?(users(:bob))

      # not endorsed
      assert !comment.can_unendorse?(users(:allroles))

      # not unendorsed already
      comment.endorser = users(:allroles)
      
      # already endorsed
      assert !comment.can_endorse?(users(:allroles))
    end
  end
  
  def test_rss_headline
    assert_equal "Forum: bugs_forum, Topic: Topic one", comments(:topic_comment).rss_headline
  end
  
  should "format rss_body" do
    assert_equal "<i>Jim P wrote:</i><br/>topic comment1", comments(:topic_comment).rss_body
  end
end