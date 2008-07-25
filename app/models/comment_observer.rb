class CommentObserver < ActiveRecord::Observer
  def after_create(comment)
    if comment.class.to_s == "IdeaComment"
      RunOncePeriodicJob.create(:job => "EmailNotifier.deliver_new_comment_notification(#{comment.id})") unless comment.idea.watchers.empty?
      #      EmailNotifier.deliver_new_comment_notification(comment) unless comment.idea.watchers.empty?
    end
  end
end