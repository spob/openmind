# == Schema Information
# Schema version: 20081021172636
#
# Table name: links
#
#  id          :integer(4)      not null, primary key
#  name        :string(30)      not null
#  url         :string(255)     not null
#  link_set_id :integer(4)
#  created_at  :datetime
#  updated_at  :datetime
#

class Link < ActiveRecord::Base
  acts_as_list :scope => :link_set
  validates_presence_of :name, :url
  validates_uniqueness_of :name, :scope => "link_set_id"
  validates_length_of :name, :maximum => 30
  
  belongs_to :link_set
  attr_accessor :should_destroy
  
  def should_destroy?
    should_destroy.to_i == 1
  end
end
