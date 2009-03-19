require File.dirname(__FILE__) + '/../test_helper'

class DateUtilsTest < ActiveSupport::TestCase 
  
  context "testing time_to_datetime" do
    t_now = Time.zone.now
    should "match date values" do
      dt_now = DateUtils.time_to_datetime t_now
      assert_equal "DateTime", dt_now.class.to_s
      assert_equal t_now, dt_now
    end
    
    context "testing today" do
      t_now = Time.zone.now
      should "match return today" do
        dt_now = DateUtils.today
        assert_equal t_now.day, dt_now.day
        assert_equal t_now.month, dt_now.month
        assert_equal t_now.year, dt_now.year
        assert_equal 0, dt_now.hour
        assert_equal 0, dt_now.min
        assert_equal 0, dt_now.sec
      end
    end
  end
end