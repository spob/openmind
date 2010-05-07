require "migration_helpers"

class AddVersionDependencies < ActiveRecord::Migration
  extend MigrationHelpers
  
  def self.up
    create_table :release_dependencies do |t|
      t.references :release, :null => false
      t.integer :depends_on_id, :null => false
      t.column :lock_version, :integer, :default => 0
      t.timestamps
    end

    add_foreign_key(:release_dependencies, :release_id, :releases)
    add_foreign_key(:release_dependencies, :depends_on_id, :releases)

    add_index :release_dependencies, [:release_id, :depends_on_id], :unique => true
  end

  def self.down
    remove_foreign_key(:release_dependencies, :release_id)
    remove_foreign_key(:release_dependencies, :depends_on_id)

    drop_table :release_dependencies
  end
end
