class Topic < ActiveRecord::Base
  belongs_to :forum
  belongs_to :user
  has_many :comments, :class_name => "TopicComment", :dependent => :delete_all,
    :order => "id ASC"   
  has_many :user_topic_reads, :dependent => :delete_all
  has_one :last_comment, :class_name => "TopicComment", :order => "id DESC"
  has_one :main_comment, :class_name => "TopicComment", :order => "id ASC"
  has_many :topic_watches
  has_many :watchers, :through => :topic_watches, :foreign_key => 'user_id'
  
  validates_presence_of :title, :user
  validates_presence_of :comment_body, :on => :create
  validates_length_of   :title, :within => 5..200, :allow_blank => true
  
  acts_as_indexed :fields => [ :title ]
  
  attr_accessor :comment_body
  
  def can_delete?
    comments.count <= 1
  end
  
  def self.list(page, per_page)
    paginate :page => page, :order => 'title ASC', 
      :per_page => per_page
  end
  
  def last_comment? comment
    return false if last_comment.nil?
    comment.id == last_comment.id
  end
  
  def last_posting_date
    last_comment.created_at unless last_comment.nil?
  end
  
  def unread_comment? user
    read = UserTopicRead.find_by_user_id_and_topic_id(user.id, id)
    return false if last_comment.nil? # should never occur
    return true if read.nil?
    read.updated_at < last_comment.created_at
  end
  
  def add_user_read user
    read = UserTopicRead.find_by_user_id_and_topic_id(user.id, id)
    if read.nil?
      read = UserTopicRead.new(:user_id => user.id)
      user_topic_reads << read
    end
    read.views += 1
    read
  end
  
  def unread_comments user
    TopicComment.find(:all,
      :select => "comments.*",
      :joins => [:topic],
      :conditions => 
        [
        "comments.topic_id = ? " +
          "and exists (" +
          "select null " +
          "from topic_watches as tw " +
          "where tw.last_checked_at < comments.created_at " +
          " and tw.topic_id = comments.topic_id " +
          "and tw.user_id = ?)", id, user.id],
      :order => "comments.id DESC")
  end
  
  def watched? user
    watchers.include? user
  end
  
  def self.notify_watchers
    # puts "Checking for topic notifications at #{Time.zone.now.to_s}"
    # Find users who have a comment more recent than the last watch check
    users = User.find(:all, :conditions => 
        ["EXISTS " +
          "(SELECT NULL FROM topic_watches AS tw " +
          "INNER JOIN topics AS t ON t.id = tw.topic_id " +
          "WHERE tw.user_id = users.id " +
          "AND t.updated_at > tw.last_checked_at)"])

    for user in users
      # puts "user #{user.email}"
      tws = TopicWatch.find_all_by_user_id(user, :include => "topic",
        :conditions => "topics.updated_at > topic_watches.last_checked_at",
        :order => "topics.forum_id")
      topics = tws.collect(&:topic)
      
      EmailNotifier.deliver_new_topic_comment_notification(topics, user)
      
      for tw in tws
        tw.last_checked_at = Time.zone.now
        tw.save
      end
    end
  end
end