class LookupCode < ActiveRecord::Base
  
  validates_presence_of :short_name, :description
  validates_numericality_of :sort_value, :only_integer => true, :allow_nil => false
  validates_length_of :short_name, :maximum => 40
  validates_length_of :description, :maximum => 50
  validates_uniqueness_of :short_name, :scope => "code_type"
  validates_uniqueness_of :description, :scope => "code_type"
  
  def self.inheritance_column
    'code_type'
  end
  
  def self.list(page, per_page)
    paginate :page => page, :order => 'code_type, sort_value', 
      :per_page => per_page
  end
  
  def can_delete?
    return true
  end
end
