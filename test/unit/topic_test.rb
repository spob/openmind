require File.dirname(__FILE__) + '/../test_helper'

class TopicTest < Test::Unit::TestCase
  fixtures :topics, :forums, :users, :comments, :topic_watches

  def test_unread_comment
    topic = topics(:bug_topic1)
    user = users(:quentin)
    
    topic = Topic.find(topic.id)
    read_count = topic.user_topic_reads.size
    
    assert topic.unread_comment?(user)
    
    topic.add_user_read user
    topic.save
    
    topic = Topic.find(topic.id)
    assert !topic.user_topic_reads.empty?
    assert read_count + 1, topic.user_topic_reads.size
    assert !topic.unread_comment?(user)
    
    sleep 1
    comment = TopicComment.new(:user_id => users(:aaron).id, :body => 'hello')
    topic.comments << comment
    topic.save
    
    topic = Topic.find(topic.id)
    assert 2, topic.comments.count
    assert topic.unread_comment?(user)
  end
  
  should "retrieve rows from list" do
    assert !Topic.list(1, 10, topics(:bug_topic1).forum).empty?
  end
  
  def test_unread_comments
    topic = topics(:bug_topic1)
    assert 0, topic.unread_comments(users(:quentin)).size
    
    comment = TopicComment.new(:user_id => users(:aaron).id, :body => 'hello')
    topic.comments << comment
    topic.save
    
    assert 1, topic.unread_comments(users(:quentin)).size
  end
  
  def test_watch_topic
    topic = topics(:bug_topic1)
    assert !topic.watchers.empty?
    
    for user in topic.watchers
      topic.watchers.delete user
    end
    assert topic.watchers.empty?
    assert topic.save
    
    user = users(:quentin)
    topic.watchers << user
    topic.save
    topic = Topic.find(topic.id)
    assert !topic.watchers.empty?
    assert 1, topic.watchers.count
    user2 = topic.watchers.first
    assert user, user2
  end
  
  def test_valid_with_attributes
    topic = Topic.new(:title => "test123", 
      :user => users(:quentin), 
      :forum => forums(:bugs_forum),
      :comment_body => "one, two, three, four")
    assert topic.valid?
  end
  
  def test_missing_title
    topic = Topic.new(:user => users(:quentin), :forum => forums(:bugs_forum))
    assert !topic.valid?
    assert_equal "can't be blank", 
      topic.errors.on(:title)
  end
  
  context "testing last comment" do
    should "calc last comment" do
      topic = comments(:topic_comment2).topic
      assert !topic.last_comment?(comments(:topic_comment2))
      assert topic.last_comment?(comments(:topic_comment3))
    end    
  end
  
  context "testing last posting date" do
    should "return nil" do
      assert_nil topics(:empty_topic).last_posting_date
    end
    
    should "return last comment date" do
      assert_equal comments(:topic_comment3).created_at, 
        topics(:bug_topic1).last_posting_date
    end
  end
  
  context "testing can_delete?" do
    should "allow" do
      assert topics(:empty_topic).can_delete?
    end
    
    should "not allow" do
      assert !topics(:bug_topic1).can_delete?
    end
  end
  
  context "testing watched?" do
    should "show watched" do
      assert topic_watches(:aaron_watcher).topic.watched?(topic_watches(:aaron_watcher).watcher)
    end
    
    should "not show watched" do
      assert !topic_watches(:aaron_watcher).topic.watched?(users(:quentin))
    end
  end
  
  context "testing notify watchers" do
    should "should notify watchers" do
      assert_nothing_thrown {
        Topic.notify_watchers
      }
    end
  end
end