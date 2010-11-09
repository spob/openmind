# == Schema Information
# Schema version: 20081021172636
#
# Table name: topics
#
#  id                   :integer(4)      not null, primary key
#  title                :string(200)     not null
#  lock_version         :integer(4)      default(0)
#  forum_id             :integer(4)      not null
#  user_id              :integer(4)      not null
#  pinned               :boolean(1)      not null
#  created_at           :datetime        not null
#  updated_at           :datetime        not null
#  topic_comments_count :integer(4)      default(0)
#  touch_counter        :integer(4)      default(0), not null
#

class Topic < ActiveRecord::Base
  has_friendly_id :title, :use_slug => true,
                  # remove accents and other diacritics from Western characters
                  :approximate_ascii => true,
                  # don't use slugs longer than 50 chars
                  :max_length => 50
  before_update :set_close_date
  acts_as_taggable
  #  acts_as_solr :fields => [:title, {:created_at => :date}]

  define_index do
    indexes title
    has created_at, updated_at
    set_property :delta => true
  end

  ajaxful_rateable :stars => 5,
                   :allow_update => true,
                   :cache_column => :rating_average
  belongs_to :forum
  belongs_to :user
  belongs_to :owner, :class_name => 'User', :foreign_key => :owner_id
  has_many :comments, :class_name => "TopicComment", :dependent => :destroy,
           :order => "id ASC"
  has_many :user_topic_reads, :dependent => :delete_all
  has_one :last_comment, :class_name => "TopicComment", :order => "id DESC"
  has_one :main_comment, :class_name => "TopicComment", :order => "id ASC"
  has_many :topic_watches, :dependent => :delete_all
  has_many :watchers, :through => :topic_watches, :foreign_key => 'user_id'

  validates_presence_of :title, :user
  validates_presence_of :comment_body, :on => :create
  validates_length_of :title, :within => 5..200, :allow_blank => true


  named_scope :by_forum,
              lambda { |forum_id| {:conditions => ['forum_id = ? or ? is null', forum_id, forum_id]} }
  named_scope :by_enterprise,
              lambda { |enterprise_id| {:joins => {:owner => :enterprise}, :conditions => {:enterprises => {:id => enterprise_id}}} }

  named_scope :tracked, :joins => [:forum], :conditions => {:forums => {:tracked => 1}}
  named_scope :closed_after,
              lambda { |closed_at| {:conditions => ['closed_at >= ?', closed_at]} }

  named_scope :open, :conditions => ['open_status = 1']
  named_scope :closed, :conditions => ['open_status != 1']
  named_scope :owned, :conditions => ['owner_id is not null']
  named_scope :unowned, :conditions => ['owner_id is null']
  named_scope :open_or_recently_closed,
              lambda { |end_date| {:conditions =>
                      ['open_status = 1 or (open_status = 0 and closed_at >= ?)', end_date]} }
  sql =
          <<-eos
topics.owner_id is not null
and
  Not Exists(Select
    Null
  From
    topic_watches
  Where
    topic_watches.user_id = topics.owner_id And
    topic_watches.topic_id = topics.id)
  eos

  named_scope :owners_who_are_not_watchers, :conditions =>
          [sql]

  attr_accessor :comment_body

  # the earliest comment that is pending a response from a moderator
  def earliest_pending_comment
    last_moderated_comment = self.comments.by_moderator.sort_by { |c| c.id }.last
    if last_moderated_comment.nil?
      nil
    else
      self.comments.find_all { |c| c.id > last_moderated_comment.id }.sort_by { |c| c.id }.first
    end
  end

  def days_comment_pending
    comment = earliest_pending_comment
    if comment.nil?
      if comments.by_moderator.empty?
        comment = comments.first
      else
        return 0
      end
    end
    (Time.zone.now - comment.created_at)/(60.0*60.0*24.0)
  end

  def set_close_date
    if !open_status and closed_at.nil?
      self.update_attribute(:closed_at, Time.zone.now)
    elsif open_status and !closed_at.nil?
      self.update_attribute(:closed_at, nil)
    end
  end

  def can_delete? user
    self.forum.mediators.include? user
  end

  def self.list(page, per_page, forum, mediator, show_open, show_closed, owner_id)
    paginate :page => page,
             :include => [:last_comment, :slug, :user, :owner, {:comments => [:user]}, :forum],
             :conditions => ["forum_id = ? " +
                     "AND ((open_status = 1 and ? = 1) OR (open_status = 0 and ? = 1))" +
                     "AND (? = -1 or (? = 0 and owner_id is null) or owner_id = ?)" +
                     "AND (? = 1 OR " +
                     "EXISTS (SELECT NULL FROM comments AS c " +
                     "WHERE c.topic_id = topics.id " +
                     "AND c.private != 1))",
                             forum.id, show_open, show_closed, owner_id, owner_id, owner_id, mediator],
             :order => "pinned DESC, last_commented_at DESC",
             :per_page => per_page
  end

  def self.set_owners_to_watchers
    Topic.owners_who_are_not_watchers.each do |t|
      TopicWatch.create!(:watcher => t.owner, :topic => t)
    end
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
    read.updated_at < last_posting_date
  end

  def add_user_read user, update_view_count=true
    read = UserTopicRead.find_by_user_id_and_topic_id(user.id, self.id, :lock => true)
    if read.nil?
      read = UserTopicRead.new(:user_id => user.id)
      user_topic_reads << read
    end
    read.views += 1 if update_view_count
    read.dummy += 1 unless update_view_count
    read.save
    read
  end

  def mediator? user
    forum.mediator? user
  end

  def can_add_comment? user
    !forum.restrict_comment_creation or mediator? user
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
                                              "where tw.last_checked_at < comments.published_at " +
                                              " and tw.topic_id = comments.topic_id " +
                                              "and tw.user_id = ?)", id, user.id],
                      :order => "comments.id DESC")
  end

  def watched? user
    watchers.include? user
  end

  def days_open
    (Time.zone.now - created_at)/(60.0*60.0*24.0) unless created_at.nil?
  end

  def self.notify_watchers
    # puts "Checking for topic notifications at #{Time.zone.now.to_s}"
    # Find users who have a comment more recent than the last watch check
    users = User.find(:all, :conditions =>
            ["EXISTS " +
                    "(SELECT NULL FROM topic_watches AS tw " +
                    "INNER JOIN topics AS t ON t.id = tw.topic_id " +
                    "WHERE tw.user_id = users.id " +
                    "AND t.last_commented_at > tw.last_checked_at)"])

    users.each do |user|
      # puts "user #{user.email}"
      tws = TopicWatch.find_all_by_user_id(user, :include => "topic",
                                           :conditions => "topics.last_commented_at > topic_watches.last_checked_at",
                                           :order => "topics.forum_id")
      topics = tws.find_all { |tw| tw.topic.forum.can_see?(user) && tw.topic.unread_comments(user).present? }.collect(& :topic)

      EmailNotifier.deliver_new_topic_comment_notification(topics, user) if user.active and user.activated_at.present?

      for tw in tws
        tw.last_checked_at = Time.zone.now
        tw.save
      end
    end
  end
end
