class LinkSet < ActiveRecord::Base
  after_update :save_links
  
  validates_presence_of :name
  validates_uniqueness_of :name 
  validates_length_of :name, :maximum => 30
  
  has_many :links, :dependent => :destroy
  
  
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
    true
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
