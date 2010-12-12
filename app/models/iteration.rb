class Iteration < ActiveRecord::Base
  belongs_to :project
  has_many :stories

  validates_presence_of :iteration_number
  validates_presence_of :start_on
  validates_presence_of :end_on
  validates_uniqueness_of :iteration_number, :case_sensitive => false, :scope => :project_id
  validates_numericality_of :iteration_number, :greater_than_or_equal_to => 1, :only_integer => true, :allow_nil => true

  named_scope :by_iteration_number,
    lambda{|num|{:conditions => { :iteration_number => num}}}
end
