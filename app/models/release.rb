class Release < ActiveRecord::Base
  has_many :ideas,
    :dependent => :destroy,
    :order => "id ASC"
  belongs_to :product
  belongs_to :release_status, :class_name => "LookupCode", 
    :foreign_key => "release_status_id"
  validates_presence_of :version
  validates_uniqueness_of :version , :scope => "product_id"
  validates_length_of :version, :maximum => 20
  
  def self.list(page, product_id, per_page)
    paginate :page => page, 
        :conditions => ['product_id = ?', product_id],
        :order => 'version', 
      :per_page => per_page
  end
  
  def self.list_by_status(status_id)
    Release.find_all_by_release_status_id(status_id,
      :order => "to_days(release_date) * if (release_date < now(),  -1, 1)")
  end
  
  def can_delete?
    ideas.empty?
  end
end
