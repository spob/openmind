class RunOncePeriodicJob < PeriodicJob
  
  def calc_next_run
    self.next_run_at = nil
  end
end