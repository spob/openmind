class CreateDepartmentsEmployees < ActiveRecord::Migration
  def self.up
    create_table :departments_employees, :id => false do |t|
      t.column :department_id, :integer
      t.column :employee_id, :integer
    end
  end
  
  def self.down
    drop_table :departments_employees
  end
end