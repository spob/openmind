require File.dirname(__FILE__) + '/../test_helper'

class TopicTest < Test::Unit::TestCase
  fixtures :topics, :users, :comments

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
end