class ReleaseDependencyGroup < LookupCode  
  has_many :release_dependencies, :foreign_key => 'dependency_group_id'

  named_scope :by_short_name, :order => "short_name ASC"
  named_scope :by_sort_value, :order => "sort_value ASC"
  
  def can_delete?
    release_dependencies.empty?
  end
  
  def self.findall include_empty = false
    list = ReleaseDependencyGroup.by_sort_value
    list.insert(0, ReleaseDependencyGroup.new(:id => 0, :short_name => "")) if include_empty
    list
  end
end