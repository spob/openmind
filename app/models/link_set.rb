# == Schema Information
# Schema version: 20081021172636
#
# Table name: link_sets
#
#  id               :integer(4)      not null, primary key
#  name             :string(30)      not null
#  created_at       :datetime
#  updated_at       :datetime
#  label            :string(30)      not null
#  default_link_set :boolean(1)      not null
#

class LinkSet < ActiveRecord::Base
  after_update :save_links
  before_save  :unset_default_link_sets
  
  validates_presence_of :name, :label
  validates_uniqueness_of :name, :case_sensitive => false
  validates_length_of :name, :label, :maximum => 30
  
  has_many :links, :order => :position, :dependent => :destroy
  has_many :forums
  
  def self.list_all include_empty
    list = LinkSet.find(:all, :order => 'name ASC')
    list.insert(0, LinkSet.new(:id => 0, :name => "")) if include_empty
    list
  end
  
  def save_links
    links.each do |o|
      if o.should_destroy?
        o.destroy
      else
        o.save(false)
      end
    end
  end
  
  def unset_default_link_sets
    # if this link set is set to true, then unset the previous default link sets
    if self.default_link_set
      for linkset in LinkSet.find_all_by_default_link_set(true)
        linkset.update_attribute(:default_link_set, false) unless linkset.id == self.id
      end
    end
  end
  
  def can_delete?
    forums.empty? && !self.default_link_set
  end
  
  def can_edit?
    true
  end
  
  def self.get_default_link_set
    LinkSet.find_by_default_link_set true
  end
  
  def link_attributes=(link_attributes)
    link_attributes.each do |attributes|
      if attributes[:id].blank?
        links.build(attributes)
      else
        link = links.detect { |o| o.id == attributes[:id].to_i }
        link.attributes = attributes
      end
    end
  end
  
  def self.list(page, per_page)
    paginate :page => page, 
      :order => 'name ASC', 
      :per_page => per_page
  end
end
