class Project < ActiveRecord::Base
  validates_presence_of :pivotal_identifier
  validates_numericality_of :pivotal_identifier, :greater_than_or_equal_to => 1, :only_integer => true, :allow_nil => true

  def self.list(page, per_page)
    paginate :page => page, :order => 'name',
    :per_page => per_page
  end
end
