class ForumMetric < ActiveRecord::Base
  belongs_to :enterprise

  named_scope :recent, :conditions => ["as_of > ?", 91.days.ago]

  def self.calculate
    enterprise_ids = User.mediators.all(:select => "distinct users.enterprise_id").collect(&:enterprise_id).find_all{|e| Topic.by_enterprise(e).owned.open.present? }
    enterprise_ids = (enterprise_ids +  ForumMetric.recent.collect(&:enterprise_id)).uniq
    enterprises = Enterprise.find_all_by_id(enterprise_ids, :order => :name)
    enterprises.each do |e|
      metric = e.forum_metrics.find_by_as_of(Date.today) || e.forum_metrics.create(:as_of => Date.today, :days_pending => 0.0, :open_count => 0, :pending_count => 0)
      open_topics = Topic.owned.by_enterprise(e).tracked.open
      metric.days_pending = (open_topics.inject(0){|sum, item| sum + item.days_comment_pending}/open_topics.size) if open_topics.size > 0
      metric.open_count = open_topics.size
      metric.pending_count = open_topics.find_all{|t| t.days_comment_pending > 0}.size
      metric.oldest_pending_days = open_topics.collect{|item| item.days_comment_pending}.sort.last || 0.0
      metric.save!
    end
  end
end
