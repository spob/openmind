require "migration_helpers"

class AddEndorserToTopicComment < ActiveRecord::Migration
  extend MigrationHelpers
  def self.up
    change_table :comments do |t|
      t.column :endorser_id, :integer, :null => true, :references => :user
    end
    add_foreign_key(:comments, :endorser_id, :users)
  end

  def self.down
    remove_foreign_key(:comments, :endorser_id)
    change_table :comments do |t|
      t.remove :endorser_id
    end
  end
end
