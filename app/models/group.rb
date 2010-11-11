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
  validates_uniqueness_of :name, :case_sensitive => false
  validates_presence_of :description
  validates_length_of   :name, :maximum => 50
  validates_length_of   :description, :maximum => 150
  has_and_belongs_to_many :users, :join_table => 'group_members', 
    :class_name => 'User', :order => 'email ASC'
  has_and_belongs_to_many :forums
  has_and_belongs_to_many :polls

  named_scope :by_name, :order => "name ASC"
  
  def can_delete?
    true
  end

  def self.findall include_empty = false
    list = Group.by_name
    list.insert(0, Group.new(:id => 0, :name => "")) if include_empty
    list
  end
  
  def self.list(page, per_page)
    paginate :page => page, :order => 'name ASC', 
      :per_page => per_page
  end
  
  def can_edit? user
   true
  end

  def name_and_description
    "#{name}#{":" if description} #{description}"
  end


  def self.assign_certified_users
    sql =
  <<-eos
      Select distinct users.*
      From portal_certified_consultants
      Inner Join users On portal_certified_consultants.consultant_email = users.email
      Where Not Exists(
          Select Null
          From group_members As gm
          Where gm.group_id = 4
            And gm.user_id = users.id)
  eos
      group = Group.find(4)    
      User.find_by_sql(sql).each do |u|
        u.groups << group
        u.save!
      end
  end
end
