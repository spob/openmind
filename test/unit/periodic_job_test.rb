require File.dirname(__FILE__) + '/../test_helper'

class PeriodicJobTest < Test::Unit::TestCase
  fixtures :periodic_jobs

  def test_jobs_should_run
    jobs = PeriodicJob.find_jobs_to_run
    assert jobs.include?(periodic_jobs(:run_once_job_null_next_run))
    assert !jobs.include?(periodic_jobs(:run_once_job_future_next_run))    
    assert jobs.include?(periodic_jobs(:run_once_job_past_next_run))    
  end
  
  def test_calc_next_date_run_once
    assert_nil periodic_jobs(:run_once_job_null_next_run).calc_next_run
  end
  
  def test_calc_next_date_run_interval
    # within a second
    next_job = periodic_jobs(:run_interval_job_past_last_run_30).calc_next_run
    next_job.save
    assert next_job.next_run_at.between?(Time.zone.now + 29, Time.zone.now + 31)
    assert_equal periodic_jobs(:run_interval_job_past_last_run_30).interval, next_job.interval
    assert_equal periodic_jobs(:run_interval_job_past_last_run_30).job, next_job.job
  end
  
  def test_calc_next_date_run_at
    hours = Time.zone.now.hour
    minutes = Time.zone.now.min + 5
    #    puts "#{"%02d" % hours}:#{"%02d" % minutes}"
    if minutes >= 60
      hours += 1
      minutes = minutes - 60
    end
    #    puts "#{"%02d" % hours}:#{"%02d" % minutes}"
    time = Time.parse("#{"%02d" % hours}:#{"%02d" % minutes}")
    next_job = periodic_jobs(:run_interval_job_never_run_at_future).calc_next_run
    next_job.save
    assert_equal time, next_job.next_run_at
    assert_equal periodic_jobs(:run_interval_job_never_run_at_future).run_at_minutes, 
      next_job.run_at_minutes
    assert_equal periodic_jobs(:run_interval_job_never_run_at_future).job, 
      next_job.job
    
    next_job = periodic_jobs(:run_interval_job_recently_run_at_future).calc_next_run
    next_job.save
    assert_equal time, next_job.next_run_at
    assert_equal periodic_jobs(:run_interval_job_recently_run_at_future).run_at_minutes,
      next_job.run_at_minutes
    assert_equal periodic_jobs(:run_interval_job_recently_run_at_future).job, 
      next_job.job
    
    time = 1.days.since
    hours = (periodic_jobs(:run_interval_job_run_at_past).run_at_minutes)/60
    minutes = periodic_jobs(:run_interval_job_run_at_past).run_at_minutes - hours * 60
    #    puts "#{"%02d" % hours}:#{"%02d" % minutes}"
    if minutes >= 60
      hours += 1
      minutes = minutes - 60
    end
    #    puts "#{"%02d" % hours}:#{"%02d" % minutes}"
    time = Time.parse("#{"%02d" % hours}:#{"%02d" % minutes}", time)
    #    puts "#{time}"
    next_job = periodic_jobs(:run_interval_job_run_at_past).calc_next_run
    next_job.save
    assert_equal time.day, next_job.next_run_at.day
    assert_equal time.hour, next_job.next_run_at.hour
    assert_equal time.min, next_job.next_run_at.min
    assert_equal periodic_jobs(:run_interval_job_run_at_past).run_at_minutes,
      next_job.run_at_minutes
    assert_equal periodic_jobs(:run_interval_job_run_at_past).job, 
      next_job.job
  end
  
  def test_run
    assert_nothing_raised {
      periodic_jobs(:run_once_job_null_next_run).run!
      PeriodicJob.run_jobs
    }
  end
end