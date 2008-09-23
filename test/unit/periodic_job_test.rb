require File.dirname(__FILE__) + '/../test_helper'

class PeriodicJobTest < Test::Unit::TestCase
  fixtures :periodic_jobs

  def test_should_run_job
    assert_nothing_thrown { periodic_jobs(:run_once_job).run! }
  end

  def test_should_find_run_once_job
    assert RunOncePeriodicJob.find_all_need_to_run.include?(periodic_jobs(:run_once_job))
  end

  def test_should_not_find_run_job_already_run
    assert !RunOncePeriodicJob.find_all_need_to_run.include?(periodic_jobs(:run_once_job_to_be_deleted))
  end

  def test_should_find_run_interval_job
    assert RunIntervalPeriodicJob.find_all_need_to_run.include?(periodic_jobs(:run_interval_job_needs_run))        
  end

  def test_should_not_find_run_interval_job_not_within_interval
    assert !RunIntervalPeriodicJob.find_all_need_to_run.include?(periodic_jobs(:run_interval_job_does_not_need_run))
  end

  def test_should_cleanup_old_jobs
    jobs_count = RunOncePeriodicJob.count

    assert periodic_jobs(:run_once_job_to_be_deleted).last_run_at
    RunOncePeriodicJob.cleanup

    assert jobs_count - 1, RunOncePeriodicJob.count
  end

  def test_should_find_run_at_job_2_days_all
    assert RunAtPeriodicJob.find_all_need_to_run.include?(periodic_jobs(:run_at_job_2_days_old))        
  end

  def test_should_find_run_at_never_run
    assert RunAtPeriodicJob.find_all_need_to_run.include?(periodic_jobs(:run_at_job_never_run))        
  end

  def test_should_find_run_at_just_run
    job = periodic_jobs(:run_at_job_just_run)
    assert !RunAtPeriodicJob.find_all_need_to_run.include?(job) 
    job.run_at_minutes = 23*60+59
    job.save
    job = PeriodicJob.find(job.id)
    assert !RunAtPeriodicJob.find_all_need_to_run.include?(job)        
  end

  def test_run_at_job_run_yesterday
    job = periodic_jobs(:run_at_job_run_yesterday)
    minutes = Time.zone.now.hour * 60 + Time.zone.now.min
    job.run_at_minutes = minutes + 3
    job.save
    job = PeriodicJob.find(job.id)
    assert !RunAtPeriodicJob.find_all_need_to_run.include?(job) 
    job.run_at_minutes = minutes - 3
    job.save
    job = PeriodicJob.find(job.id)       
    assert RunAtPeriodicJob.find_all_need_to_run.include?(job) 
  end
end