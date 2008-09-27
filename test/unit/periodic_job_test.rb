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
    assert periodic_jobs(:run_interval_job_past_last_run_30).calc_next_run.between?(Time.zone.now + 29, Time.zone.now + 31)
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
    assert_equal time,
      periodic_jobs(:run_interval_job_never_run_at_future).calc_next_run
    assert_equal time,
      periodic_jobs(:run_interval_job_recently_run_at_future).calc_next_run
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
    assert_equal time.day,
      periodic_jobs(:run_interval_job_run_at_past).calc_next_run.day
    assert_equal time.hour,
      periodic_jobs(:run_interval_job_run_at_past).calc_next_run.hour
    assert_equal time.min,
      periodic_jobs(:run_interval_job_run_at_past).calc_next_run.min
  end
  
  def test_run
    assert_nothing_raised {
      periodic_jobs(:run_once_job_null_next_run).run!
      PeriodicJob.run_jobs
    }
  end
end