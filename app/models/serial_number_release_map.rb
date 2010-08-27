class SerialNumberReleaseMap < ActiveRecord::Base
  belongs_to :serial_number
  belongs_to :release
end
