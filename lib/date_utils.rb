# 
# To change this template, choose Tools | Templates
# and open the template in the editor.
 

class DateUtils
  def self.time_to_datetime t
    return nil if t.nil?
    # convert to seconds + microseconds into a fractional number of seconds
    seconds = t.sec + Rational(t.usec, 10**6)
    
    # Convert to UTC offset
    offset = Rational(t.utc_offset, 60*60*24)
    DateTime.new(t.year, t.month, t.day, t.hour, t.min, seconds, offset)
  end
  
  def self.truncate_datetime t
    return nil if t.nil?
    # convert to seconds + microseconds into a fractional number of seconds
    
    DateTime.new(t.year, t.month, t.day, 0, 0, 0, 0)
  end
end
