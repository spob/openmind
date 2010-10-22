class ForumMetric < ActiveRecord::Base
  belongs_to :enterprise
  
  named_scope :last_3_months, :conditions => ["as_of > ?", 3.months.ago]
  
  def self.calculate
    enterprise_ids = User.mediators.all(:select => "distinct users.enterprise_id").collect(&:enterprise_id).find_all{|e| Topic.by_enterprise(e).owned.present? }
    enterprises = Enterprise.find_all_by_id(enterprise_ids, :order => :name)
    enterprises.each do |e|
      metric = e.forum_metrics.find_by_as_of(Date.today) || e.forum_metrics.create(:as_of => Date.today, :days_pending => 0.0, :open_count => 0)
      @topics = Topic.owned.by_enterprise(e).tracked.open
      metric.days_pending = (@topics.inject(0){|sum, item| sum + item.days_comment_pending}/@topics.size) if @topics.size > 0
      metric.open_count = @topics.size
      metric.save!
    end
  end
end
