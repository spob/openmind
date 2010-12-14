class FixStoryIndex < ActiveRecord::Migration
  def self.up
    remove_index :stories, [:pivotal_identifier]
    add_index :stories, [:iteration_id, :pivotal_identifier], :unique => true
  end

  def self.down
    remove_index :stories, [:iteration_id, :pivotal_identifier]
    add_index :stories, [:pivotal_identifier], :unique => true
  end
end
