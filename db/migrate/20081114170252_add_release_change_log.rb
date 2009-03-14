require "migration_helpers"

class AddReleaseChangeLog < ActiveRecord::Migration
  extend MigrationHelpers

  def self.up
    create_table :release_change_logs, :options => 'ENGINE=InnoDB DEFAULT CHARSET=utf8' do |t|
      t.references :release, :null => false
      t.references :user, :null => false
      t.text :message, :null => false
      t.datetime :processed_at, :null => true
      t.timestamps
    end

    add_foreign_key(:release_change_logs, :release_id, :releases)
    add_foreign_key(:release_change_logs, :user_id, :users)
  end

  def self.down
    remove_foreign_key(:release_change_logs, :release_id)
    remove_foreign_key(:release_change_logs, :user_id)

    drop_table :release_change_logs
  end
end
