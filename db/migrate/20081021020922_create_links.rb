require "migration_helpers"

class CreateLinks < ActiveRecord::Migration
  extend MigrationHelpers
  
  def self.up
    create_table :links do |t|
      t.string :name, :limit => 30, :null => false
      t.string :url, :null => false
      t.references :link_set
      t.timestamps
    end
    
    add_foreign_key(:links, :link_set_id, :link_sets)
  end

  def self.down
    remove_foreign_key(:links, :link_set_id)
    
    drop_table :links
  end
end
