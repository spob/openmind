require "migration_helpers"

class CreateComments < ActiveRecord::Migration
  extend MigrationHelpers
  
  def self.up
    create_table :comments, :options => 'ENGINE=InnoDB DEFAULT CHARSET=utf8' do |t|
      t.references :user, :null => false
      t.references :idea, :null => false
      t.column :body, :string, :null => false
      t.timestamps
      t.column :lock_version, :integer, :default => 0
    end
    
    add_foreign_key(:comments, :user_id, :users)
    add_foreign_key(:comments, :idea_id, :ideas)
  end

  def self.down
    remove_foreign_key(:comments, :user_id)
    remove_foreign_key(:comments, :idea_id)
    
    drop_table :comments
  end
end
