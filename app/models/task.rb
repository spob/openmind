class Task < ActiveRecord::Base
  belongs_to :story
  has_many :task_estimates, :order => "as_of"
end
