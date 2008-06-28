class Poll < ActiveRecord::Base
  after_update :save_options
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
  
  def option_attributes=(option_attributes)
    option_attributes.each do |attributes|
      if attributes[:id].blank?
        poll_options.build(attributes)
      else
        option = poll_options.detect { |o| o.id == attributes[:id].to_i }
        option.attributes = attributes
      end
    end
  end
  
  def save_options
    poll_options.each do |o|
      o.save(false)
    end
  end
end
