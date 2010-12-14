require "migration_helpers"

class FixStoryIndex < ActiveRecord::Migration
  extend MigrationHelpers
  
  def self.up
    remove_foreign_key(:stories, :iteration_id)
    add_index :stories, [:iteration_id, :pivotal_identifier], :unique => true
    remove_index :stories, [:pivotal_identifier]
    add_foreign_key(:stories, :iteration_id, :iterations)

    remove_foreign_key(:tasks, :story_id)
    add_index :tasks, [:story_id, :pivotal_identifier], :unique => true
    remove_index :tasks, [:pivotal_identifier]
    add_foreign_key(:tasks, :story_id, :stories)
  end

  def self.down
    remove_foreign_key(:stories, :iteration_id)
    add_index :stories, [:pivotal_identifier]
    remove_index :stories, [:iteration_id, :pivotal_identifier]
    add_foreign_key(:stories, :iteration_id, :iterations)

    remove_foreign_key(:tasks, :story_id)
    add_index :tasks, [:pivotal_identifier]
    remove_index :tasks, [:story_id, :pivotal_identifier]
    add_foreign_key(:tasks, :story_id, :stories)
  end
end
