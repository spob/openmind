class CreateEmployees < ActiveRecord::Migration
  def self.up
    create_table :employees do |t|
      t.column :name, :string
      t.column :manager_id, :integer
    end
  end
  
  def self.down
    drop_table :employees
  end
end