# == Schema Information
# Schema version: 20081021172636
#
# Table name: products
#
#  id           :integer(4)      not null, primary key
#  name         :string(30)      not null
#  description  :string(200)     not null
#  active       :boolean(1)      default(TRUE), not null
#  created_at   :datetime        not null
#  lock_version :integer(4)      default(0)
#  updated_at   :datetime        not null
#

class Product < ActiveRecord::Base
  validates_presence_of :name, :description
  validates_uniqueness_of :name 
  validates_length_of :name, :maximum => 30
  validates_length_of :description, :maximum => 200
  
  has_many :releases,
    :dependent => :destroy, :order => "release_date ASC"
  has_many :ideas,
    :dependent => :destroy, :order => "id ASC"
  
  def self.list(page, per_page)
    paginate :page => page, :order => 'name', 
      :per_page => per_page
  end
  
  def can_delete?
    ideas.empty? and releases.empty?
  end
  
  def self.all_products
    Product.find(:all, :order => "name") 
  end
  
  def self.all_active_products
    Product.find_all_by_active(true, :order => "name") 
  end
  
  def current_release
   releases.find(:first, 
     :conditions => 'release_date <= now()', 
     :order => "release_date desc")
  end
  
  def current_release_version
    r = current_release
    r.version unless r.nil?
  end
end
