class Link < ActiveRecord::Base
  validates_presence_of :name, :url
  validates_uniqueness_of :name, :scope => "link_set_id"
  validates_length_of :name, :maximum => 30
  
  belongs_to :link_set
  attr_accessor :should_destroy
  
  def should_destroy?
    should_destroy.to_i == 1
  end
end
