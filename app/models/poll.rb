class Poll < ActiveRecord::Base
  validates_presence_of :close_date, :title
  validates_uniqueness_of :title 
  validates_length_of :title, :maximum => 120
  
  has_many :poll_options,
    :dependent => :destroy
  
  def can_delete?
    true
  end
  
  def self.list(page, per_page)
    paginate :page => page, :order => 'close_date', 
      :per_page => per_page
  end
end
