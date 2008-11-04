require "migration_helpers"

class AddPollOptionsUsers < ActiveRecord::Migration
  extend MigrationHelpers
  
  def self.up
    create_table :poll_user_responses, :id => false  do |t|
      t.references :user, :null => false
      t.references :poll_option, :null => false
      t.column :lock_version, :integer, :default => 0
      t.timestamps
    end
    
    add_foreign_key(:poll_user_responses, :user_id, :users)
    add_foreign_key(:poll_user_responses, :poll_option_id, :poll_options)
  end

  def self.down
    remove_foreign_key(:poll_user_responses, :user_id)
    remove_foreign_key(:poll_user_responses, :poll_option_id)
    
    drop_table :poll_user_responses
  end
end
