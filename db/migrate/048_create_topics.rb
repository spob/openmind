require "migration_helpers"

class CreateTopics < ActiveRecord::Migration
  extend MigrationHelpers
  
  def self.up
    create_table :topics, :options => 'DEFAULT CHARSET=utf8' do |t|
      t.column :title, :string, :limit => 120, :null => false
      t.column :lock_version, :integer, :default => 0
      t.references :forum, :null => false
      t.references :user, :null => false
      t.column :pinned, :boolean, :default => false, :null => false
      t.timestamps
    end
    
    add_foreign_key(:topics, :user_id, :users)
    add_foreign_key(:topics, :forum_id, :forums)
    
    add_index :topics, :title, :unique => false
  end

  def self.down
    drop_table :topics
  end
end
