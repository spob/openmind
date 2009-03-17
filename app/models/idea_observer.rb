class IdeaObserver < ActiveRecord::Observer
  def after_create(idea)
    minutes = APP_CONFIG['minutes_to_send_vote_reminder'].to_i
    RunOncePeriodicJob.create(
      :job => "Idea.send_reminder_to_vote(#{idea.id})",
      :next_run_at => Time.zone.now + minutes.minutes) if minutes >= 0
  end
end