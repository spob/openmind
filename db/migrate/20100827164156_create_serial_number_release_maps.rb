require "migration_helpers"

class CreateSerialNumberReleaseMaps < ActiveRecord::Migration
  extend MigrationHelpers
  
  def self.up
    create_table :serial_number_release_maps do |t|
      t.references :serial_number, :null => false
      t.references :release, :null => false
      t.timestamps
      t.datetime :disabled_at
    end
    add_foreign_key(:serial_number_release_maps, :serial_number_id, :serial_numbers)
    add_foreign_key(:serial_number_release_maps, :release_id, :releases)
    add_index :serial_number_release_maps, [:serial_number_id, :release_id], 
    :name => ':serial_number_release_maps_sn_and_release', :unique => true
  end

  def self.down
    remove_foreign_key(:serial_number_release_maps, :serial_number_id)
    remove_foreign_key(:serial_number_release_maps, :release_id )
    
    drop_table :serial_number_release_maps
  end
end
