require "migration_helpers"

class CreateSerialNumberReleaseMapHistories < ActiveRecord::Migration
  extend MigrationHelpers
  
  def self.up
    create_table :serial_number_release_map_histories do |t|
      t.string :action
      t.references :serial_number_release_map, :null => false
      t.timestamps
    end
    add_foreign_key(:serial_number_release_map_histories, :serial_number_release_map_id, :serial_number_release_maps)
  end

  def self.down
    remove_foreign_key(:serial_number_release_map_histories, :serial_number_release_map_id)
    drop_table :serial_number_release_map_histories
  end
end
