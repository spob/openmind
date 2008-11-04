require "migration_helpers"

class CreatePollOptions < ActiveRecord::Migration
  extend MigrationHelpers
  
  def self.up
    create_table :poll_options do |t|
      t.column :description, :string, :limit => 80, :null => false
      t.references :poll, :null => false
      t.column :lock_version, :integer, :default => 0
      t.timestamps
    end
    
    add_foreign_key(:poll_options, :poll_id, :polls)
  end

  def self.down
    remove_foreign_key(:poll_options, :poll_id)
    
    drop_table :poll_options
  end
end
