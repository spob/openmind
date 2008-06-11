class CreateDepartments < ActiveRecord::Migration
  def self.up
    create_table :departments do |t|
      t.column :name, :string
      t.column :manager_id, :integer
    end
  end
  
  def self.down
    drop_table :departments
  end
end