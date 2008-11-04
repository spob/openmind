require "migration_helpers"

class AddLinkSetReference < ActiveRecord::Migration
  extend MigrationHelpers
  
  def self.up
    change_table :forums do |t|
      t.references :link_set, :null => true
    end
    
    add_foreign_key(:forums, :link_set_id, :link_sets)
  end

  def self.down
    change_table :forums do |t|
      t.remove :link_set_id
    end
  end
end
