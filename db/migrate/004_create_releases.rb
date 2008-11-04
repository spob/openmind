require "migration_helpers"

class CreateReleases < ActiveRecord::Migration
  extend MigrationHelpers

  def self.up
    create_table :releases do |t|
      t.column :version,  :string, :limit => 20, :null => false
      t.references :product,  :null => false
      t.references :release_status, :null => false
      t.timestamps
      t.column :lock_version, :integer, :default => 0
    end
    
    add_foreign_key(:releases, :product_id, :products)
    add_foreign_key(:releases, :release_status_id, :lookup_codes)
    add_index :releases, :version, :unique => true
  end

  def self.down
    remove_foreign_key(:releases, :product_id)
    remove_foreign_key(:releases, :release_status_id)
    
    drop_table :releases
  end
end
