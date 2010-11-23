# == Schema Information
# Schema version: 20081021172636
#
# Table name: lookup_codes
#
#  id           :integer(4)      not null, primary key
#  code_type    :string(30)      not null
#  short_name   :string(40)      not null
#  description  :string(50)      not null
#  sort_value   :integer(4)      default(100), not null
#  created_at   :datetime        not null
#  lock_version :integer(4)      default(0)
#  updated_at   :datetime        not null
#

class ForumGroup < LookupCode  
  has_many :forums, :order => 'display_order ASC, name ASC'
  
  def self.list_all user
    groups = ForumGroup.find(:all, :include => [{:forums => [:slug, :topics]}], :order => 'sort_value ASC')
    groups.find_all{|group| !group.forums.find_all{|forum| forum.can_see? user}.empty? }
  end
  
  def can_delete?
    forums.empty?
  end
  
  def self.findall include_empty = false
    list = ForumGroup.find(:all, :order => "sort_value")
    list.insert(0, ForumGroup.new(:id => 0, :short_name => "")) if include_empty
    list
  end
end