class ReleaseDependency < ActiveRecord::Base
  belongs_to :release
  belongs_to :depends_on, :class_name => 'Release', :foreign_key => :depends_on_id
  validates_uniqueness_of :depends_on_id, :scope => "release_id"
  validates_presence_of :release, :depends_on
end
