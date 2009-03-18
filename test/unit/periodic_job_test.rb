require File.dirname(__FILE__) + '/../test_helper'

class PeriodicJobTest < ActiveSupport::TestCase 
  fixtures :periodic_jobs
  
  context "running job" do
    should "run successfully" do
      jobs = PeriodicJob.find_jobs_to_run
      assert !jobs.empty?
      assert !jobs.include?(periodic_jobs(:run_once_job_null_next_run))
      assert !jobs.include?(periodic_jobs(:run_once_job_future_next_run))    
      assert jobs.include?(periodic_jobs(:run_once_job_past_next_run))  
      
      PeriodicJob.cleanup
    end
    
    should "fail gracefully" do
      assert_nothing_raised {
        job = PeriodicJob.create(:job => "1/0")
        assert_nil job.last_run_result
        job.run!
        assert_not_equal "Pending", job.last_run_result
        assert_not_equal "OK", job.last_run_result
        assert_not_nil job.last_run_result =~ /could not run/
      }
    end
  end
  
  context "testing list method" do
    should "return rows" do
      assert !PeriodicJob.list(1, 10).empty?
    end
  end
  
  should "not allow delete" do
    for job in PeriodicJob.list(1, 100)
      assert !job.can_delete?
    end
  end
  
  context "testing run date calculations" do
    should "return nil next run date" do
      assert_nil PeriodicJob.new.calc_next_run
    end
    
    should "set next run date to today" do
      job = PeriodicJob.create
      assert_not_nil job
      assert job.next_run_at < Time.zone.now + 10.seconds
      assert job.next_run_at > Time.zone.now - 10.seconds
    end
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
    next_job = periodic_jobs(:run_interval_job_never_run_at_future).calc_next_run
    next_job.save
    
    assert_equal calc_next_interval(5), next_job.next_run_at
    assert_equal periodic_jobs(:run_interval_job_never_run_at_future).run_at_minutes, 
    next_job.run_at_minutes
    assert_equal periodic_jobs(:run_interval_job_never_run_at_future).job, 
    next_job.job
    
    next_job = periodic_jobs(:run_interval_job_recently_run_at_future).calc_next_run
    next_job.save
    assert_equal calc_next_interval(5), next_job.next_run_at
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
  
  private
  
  def calc_next_interval interval
    #    puts "#{"%02d" % hours}:#{"%02d" % minutes}"
    hours = Time.zone.now.hour
    minutes = Time.zone.now.min + interval
    #    puts "#{"%02d" % hours}:#{"%02d" % minutes}"
    if minutes >= 60
      hours += 1
      minutes = minutes - 60
    end
    Time.zone.parse("#{"%02d" % hours}:#{"%02d" % minutes}")
  end
end