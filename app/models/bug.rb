class Bug < ActiveRecord::Base
  validates_presence_of :bug_number, :title
  belongs_to :project
end
