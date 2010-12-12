class Story < ActiveRecord::Base
  belongs_to :iteration
  has_many :tasks

  validates_numericality_of :pivotal_identifier, :greater_than_or_equal_to => 1, :only_integer => true, :allow_nil => true
  validates_uniqueness_of :pivotal_identifier, :case_sensitive => false
  validates_presence_of :story_type, :url, :status, :name, :pivotal_identifier

  named_scope :accepted,
    :conditions => { :status => "accepted"}
end
