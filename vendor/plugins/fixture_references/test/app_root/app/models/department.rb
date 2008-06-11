class Department < ActiveRecord::Base
  belongs_to  :manager,
                :class_name => 'Employee',
                :foreign_key => 'manager_id'
  has_and_belongs_to_many :employees
end