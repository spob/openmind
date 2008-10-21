class LinkSet < ActiveRecord::Base
  after_update :save_links
  
  validates_presence_of :name
  validates_uniqueness_of :name 
  validates_length_of :name, :maximum => 30
  
  has_many :links, :dependent => :destroy
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
  
  def can_delete?
    forums.empty?
  end
  
  def can_edit?
    true
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
