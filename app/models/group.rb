# == Schema Information
# Schema version: 20081021172636
#
# Table name: groups
#
#  id           :integer(4)      not null, primary key
#  name         :string(50)      not null
#  description  :string(150)     not null
#  lock_version :integer(4)      default(0)
#  created_at   :datetime        not null
#  updated_at   :datetime        not null
#

class Group < ActiveRecord::Base
  validates_presence_of :name
  validates_uniqueness_of :name 
  validates_presence_of :description
  validates_length_of   :name, :maximum => 50
  validates_length_of   :description, :maximum => 150
  has_and_belongs_to_many :users, :join_table => 'group_members', 
    :class_name => 'User', :order => 'email ASC'
  has_and_belongs_to_many :forums
  
  def can_delete?
    true
  end
  
  def self.list_all
    Group.find(:all, :order => 'name ASC')
  end
  
  def self.list(page, per_page)
    paginate :page => page, :order => 'name ASC', 
      :per_page => per_page
  end
  
  def can_edit? user
   true
  end
end
