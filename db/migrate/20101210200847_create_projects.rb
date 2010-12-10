class CreateProjects < ActiveRecord::Migration
  def self.up
    create_table :projects do |t|
      t.integer :pivotal_identifier, :null => false
      t.string :name
      t.integer :iteration_length
      t.boolean :active, :null => false, :default => true 
      t.timestamps
    end
    add_index :projects, [:pivotal_identifier], :unique => true
  end

  def self.down
    drop_table :projects
  end
end
