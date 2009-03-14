# == Schema Information
# Schema version: 20081021172636
#
# Table name: user_logons
#
#  id           :integer(4)      not null, primary key
#  user_id      :integer(4)      not null
#  lock_version :integer(4)      default(0)
#  created_at   :datetime        not null
#

class UserLogon < ActiveRecord::Base
  belongs_to :user
    
  def self.list(page, per_page)
    paginate :page => page, 
      :conditions => ['created_at > ?', (Time.zone.now - 60*60*24*90).to_s(:db)],
      :order => 'created_at desc', 
      :per_page => per_page
  end
end
