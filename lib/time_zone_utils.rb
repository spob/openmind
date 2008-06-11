# 
# time_zone_utils.rb
# 
# Created on Dec 2, 2007, 9:04:11 PM
# 
# To change this template, choose Tools | Templates
# and open the template in the editor.
 

class TimeZoneUtils
  
  def self.current_timezone
    now = Time.new
    utc = TimeZone['Edinburgh']
    offset = now - utc.adjust(now)
    
    # loop through US timezones
    for tz in TimeZone.us_zones
      if tz.utc_offset == offset
        return tz
      end
    end
    # loop through all timezones
    for tz in TimeZone.all
      if tz.utc_offset == offset
        return tz
      end
    end
  end
end
