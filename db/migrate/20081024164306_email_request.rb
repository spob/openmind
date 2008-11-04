require "migration_helpers"

class EmailRequest < ActiveRecord::Migration
  extend MigrationHelpers
  
  def self.up
    create_table :email_requests do |t|
      t.references :idea
      t.timestamps
      t.datetime :sent_at
      t.text :message
      t.string :subject, :null => false
      t.string :to_email, :null => false
      t.boolean :cc_self
      t.references :user, :null => false
      t.string :type, :null => false, :limit => 100
    end
    
    add_foreign_key(:email_requests, :idea_id, :ideas)
    add_foreign_key(:email_requests, :user_id, :users)
  end

  def self.down
    drop_table :email_requests
  end
end
