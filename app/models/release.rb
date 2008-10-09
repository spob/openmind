# == Schema Information
# Schema version: 20081008013631
#
# Table name: releases
#
#  id                :integer(4)      not null, primary key
#  version           :string(20)      not null
#  product_id        :integer(4)      not null
#  release_status_id :integer(4)      not null
#  created_at        :datetime        not null
#  lock_version      :integer(4)      default(0)
#  description       :text
#  release_date      :datetime
#  user_release_date :string(255)
#  download_url      :string(300)
#  updated_at        :datetime        not null
#  textiled          :boolean(1)      not null
#

class Release < ActiveRecord::Base
  has_many :ideas,
    :dependent => :destroy,
    :order => "id ASC"
  belongs_to :product
  belongs_to :release_status, :class_name => "LookupCode", 
    :foreign_key => "release_status_id"
  validates_presence_of :version
  validates_uniqueness_of :version, :scope => "product_id"
  validates_length_of :version, :maximum => 20
  
  xss_terminate :except => [:description]
  
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
