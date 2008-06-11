class UserLogon < ActiveRecord::Base
  belongs_to :user
    
  def self.list(page, per_page)
    paginate :page => page, 
      :conditions => ['created_at > ?', (Time.now - 60*60*24*90).to_s(:db)],
      :order => 'created_at desc', 
      :per_page => per_page
  end
end
