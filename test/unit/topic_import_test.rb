require File.dirname(__FILE__) + '/../test_helper'

class TopicTest < Test::Unit::TestCase
  fixtures :topics, :forums, :users, :comments
  
  context "testing bad topic imports" do
    should "find bad forum" do
      topic_count = Topic.find(:all).size
      ti = create_topic_import "xxx", "yyy", "asdf"
      TopicImport.process
      ti = TopicImport.find(ti)
      assert_equal "Forum not found: xxx", ti.status
      assert_equal topic_count, Topic.find(:all).size
    end

    should "find bad user" do
      topic_count = Topic.find(:all).size
      ti = create_topic_import forums(:bugs_forum).name, "yyy", "xxx@x.com"
      TopicImport.process
      ti = TopicImport.find(ti)
      assert_equal "User not found: xxx@x.com", ti.status
      assert_equal topic_count, Topic.find(:all).size
    end
  end

  context "testing good topic imports" do
    should "create new topic" do
      topic_count = Topic.find(:all).size
      ti = create_topic_import forums(:bugs_forum).name, 
        "a new dummy topic",
        users(:bob).email
      TopicImport.process
      ti = TopicImport.find(ti)
      assert_equal "OK", ti.status
      assert_equal topic_count + 1, Topic.find(:all).size
      topic = Topic.find_by_title("a new dummy topic")
      assert_not_nil topic
      assert 1, topic.comments.size
      assert "abc", topic.comments.first.body
    end

    should "user existing topic" do
      topic_count = Topic.find(:all).size
      comment_count = topics(:bug_topic1).comments.size
      ti = create_topic_import forums(:bugs_forum).name, 
        topics(:bug_topic1).title,
        users(:bob).email
      TopicImport.process
      ti = TopicImport.find(ti)
      assert_equal "OK", ti.status
      assert_equal topic_count, Topic.find(:all).size
      topic = Topic.find_by_title(topics(:bug_topic1).title)
      assert_not_nil topic
      assert comment_count + 1, topic.comments.size
    end
  end

  private

  def create_topic_import forum_name, topic_title, user_email
    TopicImport.create(
        :forum_name => forum_name,
        :topic_title => topic_title,
        :user_email => user_email,
        :comment_body => "abc")
  end
end