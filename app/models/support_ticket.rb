class SupportTicket < ActiveRecord::Base
  validates_presence_of :serial_number, :ticket_number
  validates_uniqueness_of :ticket_number, :scope => "serial_number", :case_sensitive => false
  
  named_scope :by_serial_number,
    lambda{|serial_number|{:conditions => { :serial_number => serial_number},
      :order => 'ticket_number DESC'}}
end