# == Schema Information
# Schema version: 20081021172636
#
# Table name: periodic_jobs
#
#  id              :integer(4)      not null, primary key
#  type            :string(255)
#  job             :text
#  interval        :integer(4)
#  last_run_at     :datetime
#  run_at_minutes  :integer(4)
#  last_run_result :string(500)
#  next_run_at     :datetime
#  run_counter     :integer(4)
#

class RunOncePeriodicJob < PeriodicJob
  
  def calc_next_run
    self.next_run_at = nil
  end
end
