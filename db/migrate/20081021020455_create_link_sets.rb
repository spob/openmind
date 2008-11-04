class CreateLinkSets < ActiveRecord::Migration
  def self.up
    create_table :link_sets do |t|
      t.string :name, :limit => 30, :null => false
      t.timestamps
    end
    
    add_index :link_sets, [:name], :unique => true
  end

  def self.down
    drop_table :link_sets
  end
end
