require File.dirname(__FILE__) + '/../test_helper'

class TopicTest < Test::Unit::TestCase
  fixtures :topics, :forums, :users, :comments, :topic_watches

  def test_unread_comment
    topic = topics(:bug_topic1)
    user = users(:quentin)
    
    topic = Topic.find(topic.id)
    assert topic.user_topic_reads.empty?
    
    assert topic.unread_comment?(user)
    
    topic.add_user_read user
    topic.save
    
    topic = Topic.find(topic.id)
    assert !topic.user_topic_reads.empty?
    assert !topic.unread_comment?(user)
    
    sleep 1
    comment = TopicComment.new(:user_id => users(:aaron).id, :body => 'hello')
    topic.comments << comment
    topic.save
    
    topic = Topic.find(topic.id)
    assert 2, topic.comments.count
    assert topic.unread_comment?(user)
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
    assert topic.watchers.empty?
    
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
    topic = Topic.new(:title => "test", :user => users(:quentin), :forum => forums(:bugs_forum))
    assert topic.valid?
  end
  
  def test_missing_title
    topic = Topic.new(:user => users(:quentin), :forum => forums(:bugs_forum))
    assert !topic.valid?
    assert_equal "can't be blank", 
      topic.errors.on(:title)
  end
end